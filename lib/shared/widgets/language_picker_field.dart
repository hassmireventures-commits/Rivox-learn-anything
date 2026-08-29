import 'package:flutter/material.dart';

import '../../core/constants/supported_languages.dart';

/// Language dropdown that snaps back if [onChanged] does not commit a new code.
///
/// Pass an async [onChanged] that returns the applied code (or null on cancel).
class LanguagePickerField extends StatefulWidget {
  const LanguagePickerField({
    super.key,
    required this.selectedCode,
    required this.onChanged,
    this.label,
  });

  final String selectedCode;
  final Future<String?> Function(String code) onChanged;
  final String? label;

  @override
  State<LanguagePickerField> createState() => _LanguagePickerFieldState();
}

class _LanguagePickerFieldState extends State<LanguagePickerField> {
  late String _displayCode;

  @override
  void initState() {
    super.initState();
    _displayCode = SupportedLanguages.normalizeCode(widget.selectedCode);
  }

  @override
  void didUpdateWidget(covariant LanguagePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = SupportedLanguages.normalizeCode(widget.selectedCode);
    if (next != SupportedLanguages.normalizeCode(oldWidget.selectedCode)) {
      _displayCode = next;
    }
  }

  Future<void> _handleChange(String? value) async {
    if (value == null) return;
    final previous = _displayCode;
    setState(() => _displayCode = value);
    final applied = await widget.onChanged(value);
    if (!mounted) return;
    if (applied == null) {
      setState(() => _displayCode = previous);
    } else {
      setState(() => _displayCode = SupportedLanguages.normalizeCode(applied));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_displayCode),
      initialValue: _displayCode,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.language_rounded),
      ),
      items: [
        for (final lang in SupportedLanguages.all)
          DropdownMenuItem(
            value: lang.code,
            child: Text('${lang.nativeName} (${lang.englishName})'),
          ),
      ],
      onChanged: _handleChange,
    );
  }
}
