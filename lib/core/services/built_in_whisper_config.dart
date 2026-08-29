/// NVIDIA Whisper Large v3 speech-to-text (interview voice answers).
///
/// Key is injected at build time: `--dart-define=WHISPER_API_KEY=...`
/// Do not commit secrets. Same nvapi format as Built-in LLM keys.
class BuiltInWhisperConfig {
  BuiltInWhisperConfig._();

  /// NVCF-hosted Whisper Large v3 (HTTP ASR). integrate.api.nvidia.com returns 404.
  static const String functionId = 'b702f636-f60c-4a3d-a6f4-f3568c13bd7d';
  static const String baseUrl =
      'https://$functionId.invocation.api.nvcf.nvidia.com';
  static const String model = 'openai/whisper-large-v3';
  /// Voice interview always transcribes in English via Whisper.
  static const String interviewLanguage = 'en-US';
  static const Duration requestTimeout = Duration(seconds: 120);
  static const Duration maxRecordingDuration = Duration(minutes: 3);

  /// Live transcription: how much audio to buffer before sending a chunk.
  static const Duration liveChunkInterval = Duration(seconds: 4);
  /// Skip chunks shorter than this — too little audio to transcribe usefully.
  static const Duration liveChunkMinDuration = Duration(milliseconds: 500);
  static const int liveSampleRate = 16000;
  static const int liveChannels = 1;
  static const int liveBitsPerSample = 16;

  static const String _apiKeyDefine = String.fromEnvironment('WHISPER_API_KEY');

  static String get apiKey => _apiKeyDefine.trim();

  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Secure-storage identifier for an optional user-provided key
  /// (Settings → Voice interview). Only the key swaps — model, base URL,
  /// and request shape stay fixed to this config.
  static const String userKeyStorageId = 'whisper-stt-user';
}
