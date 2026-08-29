import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../data/secure/secure_key_storage.dart';
import '../error/app_exception.dart';
import '../locale/locale_utils.dart';
import 'built_in_whisper_config.dart';

/// Records microphone audio and transcribes via NVIDIA Whisper NIM.
///
/// Supports an optional user-provided API key (Settings → Voice interview).
/// Only the key is swappable — model, base URL, and request shape always
/// follow [BuiltInWhisperConfig] so a user key hits the exact same contract
/// the built-in key does.
class WhisperSttService {
  WhisperSttService({AudioRecorder? recorder, SecureKeyStorage? secureStorage})
      : _recorder = recorder ?? AudioRecorder(),
        _secureStorage = secureStorage ?? SecureKeyStorage();

  final AudioRecorder _recorder;
  final SecureKeyStorage _secureStorage;
  String? _activePath;

  StreamSubscription<Uint8List>? _liveSub;
  final BytesBuilder _livePending = BytesBuilder(copy: false);
  Timer? _liveChunkTimer;
  bool _liveChunkInFlight = false;
  String _liveTranscript = '';
  bool _liveActive = false;
  String? _liveLanguage;

  bool get isConfigured => BuiltInWhisperConfig.hasApiKey;
  bool get isLiveActive => _liveActive;

  /// True if either a user-provided key or the build-time key is available.
  Future<bool> hasAnyApiKey() async {
    final user = await getUserApiKey();
    return (user != null && user.isNotEmpty) || BuiltInWhisperConfig.hasApiKey;
  }

  /// User-provided key, if the user has added their own (Settings → Voice interview).
  Future<String?> getUserApiKey() =>
      _secureStorage.getApiKey(BuiltInWhisperConfig.userKeyStorageId);

  Future<void> setUserApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      await clearUserApiKey();
      return;
    }
    await _secureStorage.saveApiKey(BuiltInWhisperConfig.userKeyStorageId, trimmed);
  }

  Future<void> clearUserApiKey() =>
      _secureStorage.deleteApiKey(BuiltInWhisperConfig.userKeyStorageId);

  /// Resolves the key to send: user-provided key takes priority, else the
  /// build-time key. Model, base URL, and request shape never change.
  Future<String> _resolveApiKey() async {
    final user = await getUserApiKey();
    if (user != null && user.isNotEmpty) return user;
    return BuiltInWhisperConfig.apiKey;
  }

  Future<bool> ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (!await hasAnyApiKey()) {
      throw const UnknownException('Voice interview is not configured on this build.');
    }
    if (!await ensureMicPermission()) {
      throw const UnknownException('Microphone permission denied.');
    }
    if (await _recorder.isRecording()) return;

    final dir = await getTemporaryDirectory();
    _activePath = p.join(
      dir.path,
      'interview_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _activePath!,
    );
  }

  Future<bool> get isRecording => _recorder.isRecording();

  /// Stops recording and transcribes with Whisper for voice interview (always English).
  Future<String> stopAndTranscribeInterview() =>
      stopAndTranscribe(language: BuiltInWhisperConfig.interviewLanguage);

  /// Stops recording (if active) and returns transcript text.
  Future<String> stopAndTranscribe({String? language}) async {
    final path = await _finishRecording();
    if (path == null) {
      throw const UnknownException('No recording found.');
    }
    final file = File(path);
    if (!file.existsSync()) {
      throw const UnknownException('No recording found.');
    }
    final bytes = await file.length();
    if (bytes < 512) {
      throw const UnknownException('Recording too short. Speak for at least one second.');
    }
    try {
      return await _transcribeFile(
        path,
        language: language ?? whisperLanguageCode('en'),
      );
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
      _activePath = null;
    }
  }

  Future<void> cancelRecording() async {
    await _teardownLive();
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    final path = _activePath;
    _activePath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Future<String?> _finishRecording() async {
    if (await _recorder.isRecording()) {
      final stopped = await _recorder.stop();
      return stopped ?? _activePath;
    }
    return _activePath;
  }

  Future<String> _transcribeFile(String path, {required String language}) async {
    final bytes = await File(path).readAsBytes();
    return _transcribeBytes(
      bytes,
      filename: p.basename(path),
      language: language,
      allowEmpty: false,
    );
  }

  // ── Live (chunked) transcription ───────────────────────────────────────

  /// Starts continuous recording and transcribes buffered audio in small
  /// chunks (every [BuiltInWhisperConfig.liveChunkInterval]), calling
  /// [onPartial] with the growing transcript as each chunk completes.
  ///
  /// Not true streaming ASR — the NVIDIA Whisper endpoint is batch-only, so
  /// this simulates "live" by re-transcribing short audio chunks in sequence.
  Future<void> startLiveTranscription({
    required void Function(String transcriptSoFar) onPartial,
    String? language,
  }) async {
    if (!await hasAnyApiKey()) {
      throw const UnknownException('Voice interview is not configured on this build.');
    }
    if (!await ensureMicPermission()) {
      throw const UnknownException('Microphone permission denied.');
    }
    await _teardownLive();

    final effectiveLanguage = language ?? whisperLanguageCode('en');
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: BuiltInWhisperConfig.liveSampleRate,
        numChannels: BuiltInWhisperConfig.liveChannels,
      ),
    );

    _liveTranscript = '';
    _liveActive = true;
    _liveLanguage = effectiveLanguage;
    _liveSub = stream.listen((chunk) => _livePending.add(chunk));
    _liveChunkTimer = Timer.periodic(
      BuiltInWhisperConfig.liveChunkInterval,
      (_) => unawaited(_flushLiveChunk(language: effectiveLanguage, onPartial: onPartial)),
    );
  }

  /// Stops live recording, flushes any remaining buffered audio, and
  /// returns the full accumulated transcript.
  Future<String> stopLiveTranscription({
    void Function(String transcriptSoFar)? onPartial,
  }) async {
    if (!_liveActive) return _liveTranscript.trim();
    _liveChunkTimer?.cancel();
    _liveChunkTimer = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _liveSub?.cancel();
    _liveSub = null;

    // Flush the tail end (awaited this time, so the last words aren't lost).
    while (_liveChunkInFlight) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await _flushLiveChunk(
      language: _liveLanguage ?? whisperLanguageCode('en'),
      onPartial: onPartial ?? (_) {},
      force: true,
    );

    _liveActive = false;
    final result = _liveTranscript.trim();
    if (result.isEmpty) {
      throw const UnknownException(
        'Could not transcribe your answer. Tap Record to try again.',
      );
    }
    return result;
  }

  Future<void> _flushLiveChunk({
    required String language,
    required void Function(String transcriptSoFar) onPartial,
    bool force = false,
  }) async {
    if (_liveChunkInFlight && !force) return;
    final minBytes = (BuiltInWhisperConfig.liveSampleRate *
            BuiltInWhisperConfig.liveChannels *
            (BuiltInWhisperConfig.liveBitsPerSample ~/ 8) *
            BuiltInWhisperConfig.liveChunkMinDuration.inMilliseconds)
        ~/
        1000;
    final pending = _livePending.takeBytes();
    if (pending.length < minBytes) {
      // Not enough audio yet — put it back for the next tick.
      if (pending.isNotEmpty) _livePending.add(pending);
      return;
    }

    _liveChunkInFlight = true;
    try {
      final wav = _wrapPcm16Wav(pending);
      final text = await _transcribeBytes(
        wav,
        filename: 'chunk.wav',
        language: language,
        allowEmpty: true,
      );
      if (text.isNotEmpty) {
        _liveTranscript = _liveTranscript.isEmpty ? text : '$_liveTranscript $text';
        onPartial(_liveTranscript);
      }
    } catch (_) {
      // Live chunks fail silently — a dropped chunk shouldn't interrupt
      // recording; the user can still see/edit the final transcript.
    } finally {
      _liveChunkInFlight = false;
    }
  }

  Future<void> _teardownLive() async {
    _liveChunkTimer?.cancel();
    _liveChunkTimer = null;
    await _liveSub?.cancel();
    _liveSub = null;
    _livePending.clear();
    _liveTranscript = '';
    _liveActive = false;
    _liveChunkInFlight = false;
    _liveLanguage = null;
  }

  /// Wraps raw 16-bit mono PCM bytes in a canonical WAV header.
  static Uint8List _wrapPcm16Wav(Uint8List pcmBytes) {
    const sampleRate = BuiltInWhisperConfig.liveSampleRate;
    const channels = BuiltInWhisperConfig.liveChannels;
    const bitsPerSample = BuiltInWhisperConfig.liveBitsPerSample;
    final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final blockAlign = channels * (bitsPerSample ~/ 8);

    final header = ByteData(44);
    void writeAscii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + pcmBytes.length, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, pcmBytes.length, Endian.little);

    return Uint8List(44 + pcmBytes.length)
      ..setRange(0, 44, header.buffer.asUint8List())
      ..setRange(44, 44 + pcmBytes.length, pcmBytes);
  }

  Future<String> _transcribeBytes(
    Uint8List bytes, {
    required String filename,
    required String language,
    required bool allowEmpty,
  }) async {
    final apiKey = await _resolveApiKey();
    final dio = Dio(
      BaseOptions(
        baseUrl: BuiltInWhisperConfig.baseUrl,
        connectTimeout: BuiltInWhisperConfig.requestTimeout,
        receiveTimeout: BuiltInWhisperConfig.requestTimeout,
        sendTimeout: BuiltInWhisperConfig.requestTimeout,
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'model': BuiltInWhisperConfig.model,
      'language': language,
      'response_format': 'json',
    });

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/v1/audio/transcriptions',
        data: form,
      );
      final data = response.data;
      final text = data?['text']?.toString().trim() ?? '';
      if (text.isEmpty && !allowEmpty) {
        throw const UnknownException('Transcription returned empty text.');
      }
      return text;
    } on DioException catch (e) {
      if (allowEmpty) rethrow;
      throw UnknownException(_dioErrorMessage(e));
    }
  }

  static String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    String? raw;
    if (data is Map) {
      final err = data['error'];
      if (err is Map && err['message'] != null) {
        raw = err['message'].toString();
      } else if (data['detail'] != null) {
        raw = data['detail'].toString();
      }
    } else if (data != null) {
      raw = data.toString();
    }
    if (raw != null) {
      final lower = raw.toLowerCase();
      if (lower.contains('inference') ||
          lower.contains('internal server') ||
          lower.contains('timeout') ||
          lower.contains('unavailable')) {
        return 'Could not transcribe your answer. Tap Record to try again.';
      }
      return raw;
    }
    if (e.response?.statusCode == 401) {
      return 'Whisper API key rejected. Rebuild with a valid WHISPER_API_KEY.';
    }
    if (e.response?.statusCode == 404) {
      return 'Speech service unavailable. Update the app to the latest version.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Could not transcribe your answer. Tap Record to try again.';
    }
    return e.message ?? 'Could not transcribe your answer. Tap Record to try again.';
  }

  Future<void> dispose() async {
    await cancelRecording();
    await _recorder.dispose();
  }
}
