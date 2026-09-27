import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../data/remote/ai/models/question_stimulus.dart';

/// Renders passage, transcript, chart, table, or cue material.
/// Returns nothing when [raw] is empty or not a known stimulus.
class QuestionStimulusView extends StatelessWidget {
  const QuestionStimulusView({super.key, required this.raw});

  final String? raw;

  @override
  Widget build(BuildContext context) {
    final stimulus = QuestionStimulus.tryParse(raw);
    if (stimulus == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stimulus.title.isNotEmpty)
                Text(
                  stimulus.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (stimulus.isTranscript) ...[
                const SizedBox(height: 8),
                _ListenButton(text: stimulus.body),
              ],
              if (stimulus.body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  stimulus.body,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
              if (stimulus.isChart) ...[
                if (stimulus.title.isNotEmpty) const SizedBox(height: 8),
                _BarChart(stimulus: stimulus),
              ],
              if (stimulus.isTable) ...[
                if (stimulus.title.isNotEmpty) const SizedBox(height: 8),
                _DataTable(stimulus: stimulus),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ListenButton extends StatefulWidget {
  const _ListenButton({required this.text});

  final String text;

  @override
  State<_ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<_ListenButton> {
  FlutterTts? _tts;
  bool _playing = false;

  FlutterTts _engine() {
    final existing = _tts;
    if (existing != null) return existing;
    final tts = FlutterTts();
    tts.setLanguage('en-US');
    tts.setSpeechRate(0.45);
    tts.setCompletionHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    tts.setCancelHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts = tts;
    return tts;
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    final tts = _engine();
    if (_playing) {
      await tts.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    await tts.stop();
    await tts.speak(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton.filledTonal(
        onPressed: _toggle,
        tooltip: _playing ? 'Stop' : 'Listen',
        icon: Icon(_playing ? Icons.stop_rounded : Icons.volume_up_rounded),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.stimulus});

  final QuestionStimulus stimulus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = stimulus.points.fold<double>(
      0,
      (m, p) => p.value.abs() > m ? p.value.abs() : m,
    );
    final scale = max == 0 ? 1.0 : max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stimulus.unit.isNotEmpty)
          Text(stimulus.unit, style: theme.textTheme.labelSmall),
        const SizedBox(height: 6),
        for (final point in stimulus.points) ...[
          Text(point.label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                flex: ((point.value.abs() / scale) * 100).round().clamp(1, 100),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                flex: (100 - ((point.value.abs() / scale) * 100).round().clamp(1, 100))
                    .clamp(1, 99),
                child: const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              Text(
                _format(point.value),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({required this.stimulus});

  final QuestionStimulus stimulus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(
          color: theme.colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
            ),
            children: [
              for (final column in stimulus.columns)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    column,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          for (final row in stimulus.rows)
            TableRow(
              children: [
                for (final cell in row)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(cell),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
