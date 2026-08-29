import 'package:flutter/services.dart';

/// Flutter ↔ Android bridge for on-device MLC inference and model download.
class LocalLlmChannel {
  LocalLlmChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.aiquiz.ai_quiz_app/local_llm';

  static const defaultSystemPrompt =
      'You are a helpful, safe app assistant. Do not generate harmful content. '
      'When asked for quiz or curriculum JSON, respond with a single valid JSON object only.';

  final MethodChannel _channel;

  Future<RamCheckResult> checkRam() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('checkRam');
      if (raw == null) {
        return const RamCheckResult(ok: false, totalRamBytes: 0, minRequiredBytes: 0);
      }
      return RamCheckResult(
        ok: raw['ok'] == true,
        totalRamBytes: (raw['totalRamBytes'] as num?)?.toInt() ?? 0,
        minRequiredBytes: (raw['minRequiredBytes'] as num?)?.toInt() ?? 0,
      );
    } on MissingPluginException {
      return const RamCheckResult(ok: false, totalRamBytes: 0, minRequiredBytes: 0);
    }
  }

  Future<bool> isModelReady({String? modelId}) async {
    try {
      final ready = await _channel.invokeMethod<bool>(
        'isModelReady',
        {if (modelId != null) 'modelId': modelId},
      );
      return ready ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> hasMlcRuntime() async {
    try {
      return await _channel.invokeMethod<bool>('hasMlcRuntime') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<int> startModelDownload({String? url, String? modelId}) async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      'startModelDownload',
      {
        if (url != null) 'url': url,
        if (modelId != null) 'modelId': modelId,
      },
    );
    return (raw?['downloadId'] as num?)?.toInt() ?? -1;
  }

  Future<DownloadStatus> getDownloadStatus({int? downloadId}) async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'getDownloadStatus',
        {if (downloadId != null) 'downloadId': downloadId},
      );
      if (raw == null) return const DownloadStatus(status: 'unknown');
      return DownloadStatus(
        status: raw['status']?.toString() ?? 'unknown',
        downloadId: (raw['downloadId'] as num?)?.toInt(),
        bytesDownloaded: (raw['bytesDownloaded'] as num?)?.toInt() ?? 0,
        bytesTotal: (raw['bytesTotal'] as num?)?.toInt() ?? -1,
      );
    } on MissingPluginException {
      return const DownloadStatus(status: 'unsupported');
    }
  }

  Future<String?> modelPath({String? modelId}) async {
    try {
      return await _channel.invokeMethod<String>(
        'modelPath',
        {if (modelId != null) 'modelId': modelId},
      );
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> deleteModel({String? modelId}) async {
    try {
      final ok = await _channel.invokeMethod<bool>(
        'deleteModel',
        {if (modelId != null) 'modelId': modelId},
      );
      return ok ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<String> generate({
    required String prompt,
    String systemPrompt = defaultSystemPrompt,
  }) async {
    try {
      final text = await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
        'systemPrompt': systemPrompt,
      });
      if (text == null || text.isEmpty) {
        throw PlatformException(
          code: 'generate_failed',
          message: 'Empty local LLM response.',
        );
      }
      return text;
    } on PlatformException {
      rethrow;
    }
  }
}

class RamCheckResult {
  const RamCheckResult({
    required this.ok,
    required this.totalRamBytes,
    required this.minRequiredBytes,
  });

  final bool ok;
  final int totalRamBytes;
  final int minRequiredBytes;
}

class DownloadStatus {
  const DownloadStatus({
    required this.status,
    this.downloadId,
    this.bytesDownloaded = 0,
    this.bytesTotal = -1,
  });

  final String status;
  final int? downloadId;
  final int bytesDownloaded;
  final int bytesTotal;

  bool get isReady => status == 'ready';
  bool get isInProgress =>
      status == 'running' || status == 'pending' || status == 'paused' || status == 'extracting';

  double? get progressFraction {
    if (bytesTotal <= 0) return null;
    return (bytesDownloaded / bytesTotal).clamp(0.0, 1.0);
  }

  String get friendlyLabel {
    switch (status) {
      case 'running':
      case 'pending':
        return 'Downloading…';
      case 'paused':
        return 'Download paused';
      case 'extracting':
        return 'Extracting model…';
      case 'ready':
        return 'Ready';
      case 'failed':
        return 'Download failed';
      case 'idle':
        return 'Not downloaded';
      default:
        return status;
    }
  }

  String get bytesLabel {
    if (bytesTotal <= 0 && bytesDownloaded <= 0) return '';
    String fmt(int b) {
      if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytesTotal > 0) return '${fmt(bytesDownloaded)} / ${fmt(bytesTotal)}';
    return fmt(bytesDownloaded);
  }
}
