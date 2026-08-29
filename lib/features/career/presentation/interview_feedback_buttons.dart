import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/locale/app_localizations_ext.dart';

/// Mailto feedback actions for voice interview results and locked state.
class InterviewFeedbackButtons extends StatelessWidget {
  const InterviewFeedbackButtons({
    super.key,
    this.quizId,
    this.personaId,
    this.compact = false,
  });

  final String? quizId;
  final String? personaId;
  final bool compact;

  Future<void> _mail(
    BuildContext context, {
    required String subject,
    required String body,
  }) async {
    String enc(String value) => Uri.encodeComponent(value).replaceAll('+', '%20');
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=${enc(subject)}&body=${enc(body)}',
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meta = [
      if (personaId != null) 'Persona: $personaId',
      if (quizId != null) 'Session: $quizId',
      'App: ${AppConstants.appName} ${AppConstants.appVersion}',
    ].join('\n');

    if (compact) {
      return OutlinedButton.icon(
        onPressed: () => _mail(
          context,
          subject: l10n.voiceInterviewFeedbackSubject,
          body: '${l10n.voiceInterviewFeedbackBodyPrompt}\n\n$meta',
        ),
        icon: const Icon(Icons.mail_outline_rounded),
        label: Text(l10n.voiceInterviewWriteFeedback),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.voiceInterviewFeedbackTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _mail(
            context,
            subject: l10n.voiceInterviewFeedbackSubject,
            body: '${l10n.voiceInterviewFeedbackBodyPrompt}\n\n$meta',
          ),
          icon: const Icon(Icons.rate_review_outlined),
          label: Text(l10n.voiceInterviewWriteFeedback),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _mail(
            context,
            subject: l10n.voiceInterviewReportSubject,
            body: '${l10n.voiceInterviewReportBodyPrompt}\n\n$meta',
          ),
          icon: const Icon(Icons.bug_report_outlined),
          label: Text(l10n.voiceInterviewReportIssue),
        ),
      ],
    );
  }
}
