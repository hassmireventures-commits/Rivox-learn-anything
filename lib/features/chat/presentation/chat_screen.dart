import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/network_service.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_quota.dart';
import '../../../core/services/built_in_chat_quota.dart';
import '../../../core/services/generation_sizing.dart';
import '../../../core/services/learner_goal_guard.dart';
import '../../../core/services/topic_goal_relevance.dart';
import '../../../data/local/models/chat_message.dart';
import '../../../data/local/repositories/chat_repository.dart';
import '../../../data/remote/ai/chat_reply_result.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/built_in_chat_quota_dialog.dart';
import '../../../shared/widgets/built_in_quota_dialog.dart';
import '../../../shared/widgets/goal_required_dialog.dart';
import 'chat_action_chip.dart';
import 'chat_generation_status.dart';

const String _chatAvatarAsset = 'assets/branding/rivox_logo.png';

/// Single continuous RAG chat thread (B1 — no multiple/named threads in v1).
///
/// Agentic pass: chat can PROPOSE (never perform on its own) a quiz or
/// learning-path generation; the learner must tap the resulting
/// [ChatActionChip] to actually start it. Grounding now reads across every
/// enabled library source regardless of goal mode (see
/// `KnowledgeRepository.allEnabledSourceUuids`) rather than the goal-scoped
/// subset quiz/path generation uses.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _uuid = Uuid();

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  String? _chatQuotaLabel;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshChatQuota();
  }

  @override
  void dispose() {
    // Chat's generation status widget is intentionally non-blocking (unlike
    // the full-screen GenerationOverlay on Create/Learn), so a user can
    // navigate away mid-generation with no explicit "continue in background"
    // tap. Hand off to the global GenerationTopBanner cleanly so uiAttached
    // doesn't stay stuck true forever.
    final job = ref.read(generationJobServiceProvider);
    if (job.isRunning && job.uiAttached) {
      job.continueInBackground();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final history = await ref.read(chatRepositoryProvider).getHistory();
    if (!mounted) return;
    setState(() {
      _messages = history;
      _loading = false;
    });
    _scrollToBottom();
  }

  /// BYOK providers aren't limited by chat quota at all — hide the label
  /// entirely in that case, matching how other quota UI in this app only
  /// shows for Built-in AI.
  Future<void> _refreshChatQuota() async {
    try {
      final resolved = await ref.read(llmManagerProvider).resolve();
      if (resolved.providerKey != BuiltInAiConfig.uuid) {
        if (mounted) setState(() => _chatQuotaLabel = null);
        return;
      }
      final snap = await BuiltInChatQuota.instance.load();
      if (!mounted) return;
      setState(() {
        _chatQuotaLabel = '${snap.remaining} of ${snap.allowance} chat messages left today';
      });
    } catch (_) {
      if (mounted) setState(() => _chatQuotaLabel = null);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();

    final userMessage = ChatMessage()
      ..uuid = _uuid.v4()
      ..role = 'user'
      ..text = text
      ..createdAt = DateTime.now();

    final chatRepository = ref.read(chatRepositoryProvider);
    await chatRepository.appendMessage(userMessage);
    if (!mounted) return;
    setState(() {
      _messages = [..._messages, userMessage];
      _sending = true;
    });
    _scrollToBottom();
    await _requestReply(text, chatRepository);
  }

  Future<void> _requestReply(String text, ChatRepository chatRepository) async {
    try {
      final learnerRepository = ref.read(learnerRepositoryProvider);
      final knowledgeRepository = ref.read(knowledgeRepositoryProvider);
      final profile = await learnerRepository.getOrCreateProfile();
      // Chat's knowledge scope is intentionally global (every enabled
      // source, any goal mode) — see KnowledgeRepository doc comment.
      final enabledSources = await knowledgeRepository.allEnabledSourceUuids();
      final sourceTypes = await knowledgeRepository.allEnabledSourceTypes();

      final result = await ref.read(chatServiceProvider).sendMessage(
            latestUserMessage: text,
            goalMode: profile.goalMode,
            enabledSourceUuids: enabledSources,
            sourceTypes: sourceTypes,
          );

      final assistantMessage = ChatMessage()
        ..uuid = _uuid.v4()
        ..role = 'assistant'
        ..text = result.reply
        ..createdAt = DateTime.now()
        ..contextRef = result.action != null ? jsonEncode(result.action!.toJson()) : null;
      await chatRepository.appendMessage(assistantMessage);
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, assistantMessage];
        _sending = false;
      });
      _scrollToBottom();
      unawaited(_refreshChatQuota());
    } on BuiltInChatQuotaExceededException {
      if (!mounted) return;
      setState(() => _sending = false);
      final unlocked = await showBuiltInChatQuotaDialog(context);
      unawaited(_refreshChatQuota());
      if (unlocked && mounted) {
        setState(() => _sending = true);
        await _requestReply(text, chatRepository);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      await showAppErrorDialog(context, e);
    }
  }

  /// Confirm-tap sequence for a proposed quiz/path action. Nothing here runs
  /// unless the learner explicitly tapped the chip — see `ChatActionChip`.
  /// Mirrors create_quiz_screen.dart's/learn_screen.dart's pre-flight
  /// sequence (firewall, quota, sizing) without their screen-specific
  /// off-goal warning dialogs — a deliberate v1 scope reduction, see plan.
  Future<void> _confirmAction(ChatProposedAction action) async {
    final job = ref.read(generationJobServiceProvider);
    if (job.isBusy) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A generation is already running — try again once it finishes.'),
        ),
      );
      return;
    }

    try {
      await NetworkService.instance.ensureConnected();
    } catch (e) {
      if (!mounted) return;
      await showAppErrorDialog(context, e);
      return;
    }

    final learnerRepository = ref.read(learnerRepositoryProvider);
    final profile = await learnerRepository.getOrCreateProfile();
    if (!mounted) return;
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: learnerRepository)) {
      await showGoalRequiredDialog(context);
      return;
    }

    final firewallResult = await ref.read(aiRequestPipelineProvider).sanitizeTopic(action.topic);
    if (firewallResult.blocked) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firewallResult.reason ?? "That topic isn't allowed.")),
      );
      return;
    }
    final sanitizedTopic = firewallResult.sanitized;

    // Cheap, synchronous relevance heuristic only — no LLM call, unlike the
    // screens' async TopicGoalGuardrail.assess (deliberate v1 scope
    // reduction: a blocking modal doesn't translate to an inline chat chip).
    final personalization = await ref.read(personalizationProvider.future);
    final relevance = TopicGoalRelevanceGate.evaluate(
      topic: sanitizedTopic,
      goalLabel: personalization.goalContextLabel,
      goalTopics: personalization.primaryTopics,
    );
    if (relevance.level == TopicGoalRelevance.offGoal) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "That looks off-goal for your current focus, so I won't start it — "
            'you can still create it manually from the Create tab.',
          ),
        ),
      );
      return;
    }

    final providers = await ref.read(aiProvidersProvider.future);
    final activeProvider = GenerationSizing.pickActiveCloudProvider(providers);
    final isBuiltin = GenerationSizing.isBuiltinProvider(activeProvider);

    if (isBuiltin) {
      try {
        await BuiltInAiQuota.instance.ensureCanGenerate();
      } on BuiltInQuotaExceededException {
        if (!mounted) return;
        final unlocked = await showBuiltInQuotaDialog(context);
        if (unlocked && mounted) {
          await _confirmAction(action);
        }
        return;
      }
    }

    try {
      if (action.isQuiz) {
        final count = GenerationSizing.clampQuizQuestionCount(
          questionCount: action.questionCount ?? 15,
          isBuiltin: isBuiltin,
        );
        final explanations = GenerationSizing.explanationsForBuiltin(
          requested: true,
          isBuiltin: isBuiltin,
          questionCount: count,
        );
        await job.startQuiz(
          topic: sanitizedTopic,
          questionCount: count,
          difficulty: action.difficulty ?? 'medium',
          explanations: explanations,
        );
      } else {
        final modules = GenerationSizing.clampPathModuleCount(
          moduleCount: action.pathModuleCount ?? 6,
          isBuiltin: isBuiltin,
        );
        await job.startPath(focus: sanitizedTopic, moduleCount: modules);
      }
    } catch (e) {
      if (!mounted) return;
      await showAppErrorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ChatAvatar(radius: 14),
            const SizedBox(width: 10),
            const Text('Chat'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_chatQuotaLabel != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  _chatQuotaLabel!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _EmptyState(theme: theme)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_sending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _messages.length) {
                              return const _TypingBubble();
                            }
                            final message = _messages[index];
                            return _ChatBubble(
                              message: message,
                              theme: theme,
                              onConfirmAction: _confirmAction,
                            );
                          },
                        ),
            ),
            const ChatGenerationStatus(),
            const Divider(height: 1),
            _ComposerBar(
              controller: _controller,
              enabled: !_sending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ClipOval(
        child: Image.asset(
          _chatAvatarAsset,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              Icon(Icons.auto_awesome_rounded, size: radius, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ChatAvatar(radius: 28),
            const SizedBox(height: 16),
            Text(
              'Ask a follow-up question about your modules, quizzes, or library content.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.theme,
    required this.onConfirmAction,
  });

  final ChatMessage message;
  final ThemeData theme;
  final Future<void> Function(ChatProposedAction action) onConfirmAction;

  ChatProposedAction? get _decodedAction {
    final raw = message.contextRef;
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) return ChatProposedAction.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bubbleColor =
        isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final action = isUser ? null : _decodedAction;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.text,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
          if (action != null)
            ChatActionChip(action: action, onConfirm: () => onConfirmAction(action)),
        ],
      ),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: isUser
            ? bubble
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ChatAvatar(radius: 14),
                  const SizedBox(width: 8),
                  Flexible(child: bubble),
                ],
              ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ChatAvatar(radius: 14),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Ask a question…',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
