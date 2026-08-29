import 'dart:io';

import 'package:path/path.dart' as p;

class DocumentIngestionService {
  const DocumentIngestionService();

  Future<String> extractTextFromFile(String localPath) async {
    final ext = p.extension(localPath).toLowerCase().replaceFirst('.', '');
    final file = File(localPath);
    if (!file.existsSync()) {
      throw StateError('File not found: $localPath');
    }
    switch (ext) {
      case 'txt':
      case 'md':
        return file.readAsString();
      case 'pdf':
        return _extractPdfText(file);
      default:
        throw StateError('Unsupported file type: $ext');
    }
  }

  Future<String> _extractPdfText(File file) async {
    final bytes = await file.readAsBytes();
    final latin = String.fromCharCodes(bytes.where((b) => b >= 32 && b <= 126 || b == 10 || b == 13));
    final matches = RegExp(r'\(([^()\\]{4,500})\)').allMatches(latin);
    final parts = <String>[];
    for (final m in matches) {
      final t = m.group(1)?.trim() ?? '';
      if (t.length > 4 && !RegExp(r'^[\d\s\.]+$').hasMatch(t)) {
        parts.add(t);
      }
    }
    final joined = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (joined.length < 80) {
      throw StateError(
        'Could not extract enough text from PDF. Try exporting as .txt or .md.',
      );
    }
    return joined;
  }
}
