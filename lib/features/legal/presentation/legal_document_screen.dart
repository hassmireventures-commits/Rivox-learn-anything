import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.documentId});

  final String documentId;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String? _markdown;
  String? _updatedAt;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final manifestRaw = await rootBundle.loadString('assets/legal/legal_manifest.json');
      final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final docs = manifest['documents'] as Map<String, dynamic>;
      final doc = docs[widget.documentId] as Map<String, dynamic>?;
      if (doc == null) {
        setState(() => _error = 'Document not found');
        return;
      }
      _updatedAt = manifest['updatedAt'] as String?;
      final asset = doc['asset'] as String;
      final content = await rootBundle.loadString(asset);
      setState(() => _markdown = content);
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  String _title(AppLocalizations l10n) => switch (widget.documentId) {
        'privacy' => l10n.legalPrivacyTitle,
        'terms' => l10n.legalTermsTitle,
        _ => widget.documentId,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: _error != null
          ? Center(child: Text(_error!))
          : _markdown == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_updatedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          l10n.legalLastUpdated(_updatedAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedSlate,
                          ),
                        ),
                      ),
                    MarkdownBody(
                      data: _markdown!,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        h2: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        p: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
    );
  }
}
