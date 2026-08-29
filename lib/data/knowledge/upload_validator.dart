import '../../core/ai_platform/ai_policy_registry.dart';

class UploadValidationResult {
  const UploadValidationResult({required this.ok, this.reason});

  final bool ok;
  final String? reason;
}

class UploadValidator {
  const UploadValidator();

  Future<UploadValidationResult> validate({
    required String fileName,
    required int byteLength,
    AiPolicy? policy,
  }) async {
    final p = policy ?? AiPolicyRegistry.current;
    if (byteLength > p.maxUploadBytes) {
      return UploadValidationResult(
        ok: false,
        reason: 'File exceeds ${(p.maxUploadBytes / 1048576).round()} MB limit.',
      );
    }
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (!p.allowedUploadExtensions.contains(ext)) {
      return UploadValidationResult(
        ok: false,
        reason: 'File type .$ext is not supported. Use: ${p.allowedUploadExtensions.join(', ')}',
      );
    }
    return const UploadValidationResult(ok: true);
  }
}
