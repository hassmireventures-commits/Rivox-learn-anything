import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/interview_persona.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/services/built_in_whisper_config.dart';
import '../../../core/services/whisper_stt_service.dart';
import 'voice_interview_speech_coaching.dart';
import 'voice_interview_theme.dart';

/// Mic + live caption panel for voice interview open answers (NVIDIA Whisper STT).
class InterviewVoiceInputBar extends StatefulWidget {
  const InterviewVoiceInputBar({
    super.key,
    required this.stt,
    required this.onTranscript,
    this.persona,
    this.darkTheme = false,
  });

  final WhisperSttService stt;
  final ValueChanged<String> onTranscript;
  final InterviewPersona? persona;
  final bool darkTheme;

  @override
  State<InterviewVoiceInputBar> createState() => _InterviewVoiceInputBarState();
}

class _InterviewVoiceInputBarState extends State<InterviewVoiceInputBar>
    with SingleTickerProviderStateMixin {
  bool _recording = false;
  bool _busy = false;
  String _liveCaption = '';
  String _finalCaption = '';
  Timer? _elapsedTimer;
  Timer? _coachingTimer;
  int _elapsedSec = 0;
  int _coachingTipIndex = 0;
  late AnimationController _wave;

  InterviewAccent get _accent =>
      widget.persona == InterviewPersona.hr ? InterviewAccent.hr : InterviewAccent.tech;

  Color get _accentColor => _accent == InterviewAccent.hr
      ? VoiceInterviewTheme.hrAccent
      : VoiceInterviewTheme.techAccent;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _coachingTimer?.cancel();
    _wave.dispose();
    super.dispose();
  }

  void _startCoachingTimer() {
    _coachingTipIndex = 0;
    _coachingTimer?.cancel();
    _coachingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_recording) return;
      setState(() {
        _coachingTipIndex =
            (_coachingTipIndex + 1) % VoiceInterviewSpeechCoaching.rotatingTips.length;
      });
    });
  }

  void _stopCoachingTimer() {
    _coachingTimer?.cancel();
    _coachingTimer = null;
  }

  void _startElapsedTimer() {
    _elapsedSec = 0;
    _elapsedTimer?.cancel();
    final maxSec = BuiltInWhisperConfig.maxRecordingDuration.inSeconds;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_recording) return;
      final next = _elapsedSec + 1;
      if (next >= maxSec) {
        setState(() => _elapsedSec = maxSec);
        unawaited(_finishRecording());
        return;
      }
      setState(() => _elapsedSec = next);
    });
  }

  String _formatRecordingTime() {
    final m = _elapsedSec ~/ 60;
    final s = _elapsedSec % 60;
    const maxM = 3;
    return '$m:${s.toString().padLeft(2, '0')} / $maxM:00';
  }

  Future<void> _finishRecording() async {
    if (!_recording || _busy) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _liveCaption = l10n.interviewVoiceTranscribing;
    });
    _wave.stop();
    _stopElapsedTimer();
    _stopCoachingTimer();
    try {
      final text = await widget.stt.stopLiveTranscription();
      if (!mounted) return;
      setState(() {
        _finalCaption = text;
        _liveCaption = '';
      });
      widget.onTranscript(text);
    } catch (e) {
      if (!mounted) return;
      final msg = e is UnknownException
          ? e.message
          : l10n.interviewVoiceTranscribeFailed;
      _snack(msg);
      setState(() => _liveCaption = '');
    } finally {
      if (mounted) {
        setState(() {
          _recording = false;
          _busy = false;
        });
      }
    }
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  Future<void> _toggleRecording() async {
    if (_busy) return;
    final l10n = context.l10n;

    if (!await widget.stt.hasAnyApiKey()) {
      _snack(l10n.interviewVoiceNoKey);
      return;
    }

    if (_recording) {
      await _finishRecording();
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.stt.startLiveTranscription(
        language: BuiltInWhisperConfig.interviewLanguage,
        onPartial: (transcriptSoFar) {
          if (!mounted) return;
          setState(() => _liveCaption = transcriptSoFar);
        },
      );
      if (mounted) {
        setState(() {
          _recording = true;
          _finalCaption = '';
          _liveCaption = VoiceInterviewSpeechCoaching.whileRecording;
        });
        _wave.repeat();
        _startElapsedTimer();
        _startCoachingTimer();
      }
    } catch (e) {
      final msg = e.toString().contains('permission')
          ? l10n.interviewVoiceMicDenied
          : l10n.interviewVoiceTranscribeFailed;
      _snack(msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _coachingBanner({required bool highlight}) {
    final theme = Theme.of(context);
    final rotating = _recording
        ? VoiceInterviewSpeechCoaching.rotatingTips[_coachingTipIndex]
        : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? _accentColor.withValues(alpha: widget.darkTheme ? 0.18 : 0.12)
            : (widget.darkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? _accentColor.withValues(alpha: 0.55)
              : (widget.darkTheme ? Colors.white12 : theme.dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _recording ? Icons.mic_rounded : Icons.record_voice_over_outlined,
            size: 22,
            color: highlight ? _accentColor : theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VoiceInterviewSpeechCoaching.primaryTip,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.darkTheme ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                if (rotating != null) ...[
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      rotating,
                      key: ValueKey(rotating),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    VoiceInterviewSpeechCoaching.beforeRecord,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.darkTheme
                          ? Colors.white60
                          : theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final captionText = _finalCaption.isNotEmpty
        ? _finalCaption
        : (_liveCaption.isNotEmpty
            ? _liveCaption
            : VoiceInterviewSpeechCoaching.beforeRecord);
    final captionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: widget.darkTheme ? Colors.white : theme.colorScheme.onSurface,
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _coachingBanner(highlight: _recording),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.darkTheme
                ? VoiceInterviewTheme.captionBg
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _recording
                  ? _accentColor.withValues(alpha: 0.65)
                  : (widget.darkTheme ? Colors.white12 : theme.dividerColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _recording ? Icons.graphic_eq_rounded : Icons.closed_caption_rounded,
                    size: 18,
                    color: _recording ? _accentColor : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.voiceInterviewLiveCaptions,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: widget.darkTheme ? Colors.white70 : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_recording)
                    Text(
                      _formatRecordingTime(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _accentColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_recording)
                AnimatedBuilder(
                  animation: _wave,
                  builder: (context, _) {
                    return SizedBox(
                      height: 28,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(12, (i) {
                          final h = 8 + 18 * ((math.sin(_wave.value * math.pi * 2 + i) + 1) / 2);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1.5),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                height: h,
                                decoration: BoxDecoration(
                                  color: _accentColor.withValues(alpha: 0.55 + i * 0.03),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              if (_recording) const SizedBox(height: 8),
              Text(
                captionText,
                style: captionStyle?.copyWith(
                  fontStyle: _finalCaption.isEmpty && !_recording
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: _recording
                      ? _accentColor.withValues(alpha: 0.95)
                      : captionStyle.color,
                ),
              ),
              if (_recording) ...[
                const SizedBox(height: 6),
                Text(
                  VoiceInterviewSpeechCoaching.stopReminder,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: widget.darkTheme ? Colors.white54 : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (_finalCaption.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.voiceInterviewCaptionReady,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: widget.darkTheme ? Colors.white54 : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy && !_recording ? null : _toggleRecording,
          icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
          label: Text(
            _recording ? l10n.interviewVoiceStop : l10n.interviewVoiceTapMic,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _recording ? Colors.white : _accentColor,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _recording
                ? const Color(0xFFE53935)
                : _accentColor.withValues(alpha: widget.darkTheme ? 0.22 : 0.15),
            foregroundColor: _recording ? Colors.white : _accentColor,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}
