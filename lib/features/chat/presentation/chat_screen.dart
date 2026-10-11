import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_chat_quota.dart';
import '../../../core/personalization/learning_domain.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/services/agentic/learning_plan_editor.dart';
import '../../../core/services/agentic/proposed_action_runner.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/services/built_in_whisper_config.dart';
import '../../../core/services/interview_tts_service.dart';
import '../../../core/services/learner_memory_scheduler.dart';
import '../../../core/services/nvidia/vision_service.dart';
import '../../../core/services/ocr_service.dart';
import '../../library/presentation/camera_scan_screen.dart';
import '../../../data/knowledge/document_ingestion_service.dart';
import '../../../data/local/models/chat_message.dart';
import '../../../data/local/repositories/chat_repository.dart';
import '../../../data/remote/ai/chat_reply_result.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/built_in_chat_quota_dialog.dart';
import 'chat_action_chip.dart';
import 'chat_generation_status.dart';
import 'chat_inline_quiz_card.dart';
import 'chat_turn_text.dart';

const String _chatAvatarAsset = 'assets/branding/rivox_logo.png';

/// contextRef key holding a path edit's outcome: applied | failed | undone.
const String _pathEditStatusKey = 'pathEditStatus';

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
  int _generation = 0;
  String? _attachmentText;
  String? _attachmentLabel;
  String? _chatQuotaLabel;

  @override
  void initState() {
    super.initState();
    _tts.onDone(() {
      if (mounted) setState(() => _speakingUuid = null);
    });
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
    unawaited(_tts.stop());
    if (_recording) unawaited(ref.read(whisperSttServiceProvider).cancelRecording());
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

  /// Sends the composer's text, or [quickReply] (a suggestion chip or an
  /// in-chat quiz follow-up) when given. A quick reply leaves whatever the
  /// learner was typing untouched.
  Future<void> _send({String? quickReply}) async {
    final typed = (quickReply ?? _controller.text).trim();
    final text = _outgoingText(typed);
    if (text.isEmpty || _sending) return;
    if (quickReply == null) _controller.clear();
    setState(() {
      _attachmentText = null;
      _attachmentLabel = null;
    });

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

  String _outgoingText(String typed) {
    final attachment = _attachmentText?.trim();
    if (attachment == null || attachment.isEmpty) return typed;
    final clipped = attachment.length > 8000 ? attachment.substring(0, 8000) : attachment;
    return ChatTurnText(
      question: typed,
      attachmentLabel: _attachmentLabel ?? 'notes',
      attachmentBody: clipped,
    ).compose();
  }

  void _stop() {
    _generation++;
    if (!mounted) return;
    setState(() => _sending = false);
  }

  Future<void> _resend(ChatMessage message) async {
    if (_sending || message.role != 'user') return;
    final chatRepository = ref.read(chatRepositoryProvider);
    await chatRepository.deleteAfter(message.createdAt);
    if (!mounted) return;
    setState(() {
      _messages = _messages.where((m) => !m.createdAt.isAfter(message.createdAt)).toList();
      _sending = true;
    });
    _scrollToBottom();
    await _requestReply(message.text, chatRepository);
  }

  Future<void> _openTurnActions(ChatMessage message) async {
    if (_sending || message.role != 'user') return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Resend'),
                onTap: () => Navigator.pop(context, 'resend'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    if (choice == 'edit') {
      await _edit(message);
    } else if (choice == 'resend') {
      await _resend(message);
    }
  }

  Future<void> _edit(ChatMessage message) async {
    if (_sending || message.role != 'user') return;
    final turn = ChatTurnText.parse(message.text);
    final edited = await showDialog<String>(
      context: context,
      builder: (context) => _EditMessageDialog(initial: turn.displayQuestion),
    );
    if (edited == null || !mounted) return;
    final text = turn.hasAttachment
        ? ChatTurnText(
            question: edited,
            attachmentLabel: turn.attachmentLabel,
            attachmentBody: turn.attachmentBody,
          ).compose()
        : edited.trim();
    if (text.isEmpty) return;
    message.text = text;
    final chatRepository = ref.read(chatRepositoryProvider);
    await chatRepository.saveMessage(message);
    await chatRepository.deleteAfter(message.createdAt);
    if (!mounted) return;
    setState(() {
      _messages = _messages.where((m) => !m.createdAt.isAfter(message.createdAt)).toList();
      _sending = true;
    });
    _scrollToBottom();
    await _requestReply(text, chatRepository);
  }

  Future<void> _attachFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'md', 'pdf'],
    );
    final path = picked?.path;
    if (path == null || !mounted) return;
    try {
      final text = await const DocumentIngestionService().extractTextFromFile(path);
      if (!mounted) return;
      setState(() {
        _attachmentText = text.trim();
        _attachmentLabel = picked!.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _attachScan() async {
    final text = await context.push<String>('/library/scan');
    if (text == null || text.trim().isEmpty || !mounted) return;
    setState(() {
      _attachmentText = text.trim();
      _attachmentLabel = 'camera scan';
    });
  }

  bool _readingPhoto = false;
  bool _recording = false;
  bool get _speechAvailable => BuiltInWhisperConfig.hasApiKey;

  /// Everything the learner can hand the tutor, in one sheet.
  Future<void> _openAddMenu() async {
    final vision = VisionService.isAvailable;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vision)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ask about a photo'),
                subtitle: const Text('Worksheet, diagram, code, a form check'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
            if (vision)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Photo from your gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Scan pages to text'),
              onTap: () => Navigator.pop(context, 'scan'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_rounded),
              title: const Text('Upload a file'),
              subtitle: const Text('PDF, TXT, or Markdown'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'camera':
        final result = await context.push<String>('/library/scan?photo=1');
        if (result == null || !result.startsWith(CameraScanScreen.imageResultPrefix)) return;
        await _attachPhoto(result.substring(CameraScanScreen.imageResultPrefix.length), 'photo');
      case 'gallery':
        final picked = await FilePicker.pickFile(type: FileType.image);
        final path = picked?.path;
        if (path != null) await _attachPhoto(path, picked!.name);
      case 'scan':
        await _attachScan();
      case 'file':
        await _attachFile();
    }
  }

  /// Image to text with the NVIDIA vision model, attached like a file so the
  /// tutor answers about it through the normal chat pipeline. Whatever the
  /// learner already typed is passed along as a hint for what to look at.
  Future<void> _attachPhoto(String path, String label) async {
    if (!mounted) return;
    setState(() => _readingPhoto = true);
    try {
      final reader = PhotoReader(
        onDeviceOcr: (p) async {
          final ocr = OcrService();
          try {
            return await ocr.recognizeText(p);
          } finally {
            await ocr.dispose();
          }
        },
      );
      final reading = await reader.read(
        await File(path).readAsBytes(),
        learnerNote: _controller.text,
        imagePath: path,
      );
      if (!mounted) return;
      setState(() {
        _attachmentText = reading.full ? 'What the photo shows:\n${reading.text}' : reading.text;
        _attachmentLabel = label;
      });
      if (!reading.full) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Read the text in your photo. Picture details were not available right now.'),
          ),
        );
      }
      if (_controller.text.trim().isEmpty) {
        _controller.text = 'Help me with this photo.';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _readingPhoto = false);
    }
  }

  /// Tap to record, tap again to transcribe into the composer (NVIDIA
  /// Whisper). The text is left for review rather than sent automatically.
  Future<void> _toggleVoice() async {
    final stt = ref.read(whisperSttServiceProvider);
    try {
      if (!_recording) {
        await stt.startRecording();
        if (mounted) setState(() => _recording = true);
        return;
      }
      if (mounted) setState(() => _recording = false);
      final language = whisperLanguageCode(Localizations.localeOf(context).languageCode);
      final text = await stt.stopAndTranscribe(language: language);
      if (!mounted || text.trim().isEmpty) return;
      final existing = _controller.text.trim();
      _controller.text = existing.isEmpty ? text.trim() : '$existing ${text.trim()}';
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    } catch (e) {
      if (mounted) {
        setState(() => _recording = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  final InterviewTtsService _tts = InterviewTtsService();
  String? _speakingUuid;

  /// Reads a reply aloud with on-device text-to-speech (no network, no key).
  Future<void> _toggleSpeak(ChatMessage message) async {
    if (_speakingUuid == message.uuid) {
      await _tts.stop();
      if (mounted) setState(() => _speakingUuid = null);
      return;
    }
    setState(() => _speakingUuid = message.uuid);
    await _tts.speak(speakableText(message.text));
  }

  /// Markdown and symbols removed so TTS reads words, not punctuation.
  static String speakableText(String markdown) => markdown
      .replaceAll(RegExp(r'```[\s\S]*?```'), ' (code) ')
      .replaceAll(RegExp(r'[*_`#>]+'), '')
      .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Cheap local keyword heuristic (no LLM call) — true when the learner is
  /// plausibly asking about their own recent activity/progress, in which
  /// case the cached learner-memory snapshot should be force-refreshed
  /// first rather than answered off a stale (up to a day old) one.
  static const _recentActivityKeywords = [
    'how am i doing',
    'my progress',
    'my streak',
    'this week',
    'recent activity',
    'recently',
    'pattern',
    'what did i get wrong',
    'what did i miss',
    'my mistakes',
    'what did i study',
    'my accuracy',
    'how\'s my',
  ];

  static bool _looksLikeRecentActivityQuestion(String text) {
    final lower = text.toLowerCase();
    return _recentActivityKeywords.any(lower.contains);
  }

  Future<void> _requestReply(String text, ChatRepository chatRepository) async {
    final generation = _generation;
    try {
      // Every ref.read happens here, before any await, so the rest of this
      // method never touches `ref` again. Leaving chat mid-generation (or
      // the OS backgrounding the app) can dispose this widget's ref while
      // the request is still in flight; reading it again afterward (as a
      // previous version of this method did for chatServiceProvider,
      // several awaits after these first three reads) throws once ref is
      // gone, failing generation instead of letting it finish and persist.
      final learnerRepository = ref.read(learnerRepositoryProvider);
      final knowledgeRepository = ref.read(knowledgeRepositoryProvider);
      final memoryScheduler = ref.read(learnerMemorySchedulerProvider);
      final chatService = ref.read(chatServiceProvider);
      final profileRepository = ref.read(profileRepositoryProvider);
      final planEditor = LearningPlanEditor(learnerRepository);
      final profile = await learnerRepository.getOrCreateProfile();
      final userProfile = await profileRepository.getProfile();
      // Chat's knowledge scope is intentionally global (every enabled
      // source, any goal mode) — see KnowledgeRepository doc comment.
      final enabledSources = await knowledgeRepository.allEnabledSourceUuids();
      final sourceTypes = await knowledgeRepository.allEnabledSourceTypes();

      // A question about the learner's own recent activity shouldn't answer
      // off a stale (up to a day old) snapshot — force a refresh first. This
      // still respects the generation-busy skip inside trySchedule, so it
      // never fights an in-flight quiz/path/chat generation.
      if (_looksLikeRecentActivityQuestion(text)) {
        await memoryScheduler.trySchedule(force: true);
      }
      final memorySection = (await memoryScheduler.readCached())?.toPromptSection();

      if (generation != _generation) return;
      final result = await chatService.sendMessage(
            latestUserMessage: text,
            goalMode: profile.goalMode,
            enabledSourceUuids: enabledSources,
            sourceTypes: sourceTypes,
            learnerMemory: memorySection,
            learnerName: userProfile?.name,
          );

      // Action, in-chat quiz, suggestions and sources all share the one
      // contextRef JSON object (see ChatReplyResult.toContextRef) rather
      // than separate persisted fields, so all of them survive history
      // reload from one existing column.
      if (!mounted || generation != _generation) return;
      final messageUuid = _uuid.v4();
      var contextRef = result.toContextRef();
      // Self-healing: a path edit is applied right away (reversible, see
      // AgentAutonomyPolicy) rather than waiting for a tap. Its outcome is
      // persisted with the message so a reload shows it but never re-runs it.
      final pathEdit = result.pathEdit;
      if (pathEdit != null) {
        PathSnapshot? snapshot;
        try {
          snapshot = await planEditor.apply(pathEdit);
        } catch (_) {
          snapshot = null;
        }
        if (snapshot != null) _pathSnapshots[messageUuid] = snapshot;
        contextRef = _withPathEditStatus(contextRef, snapshot != null ? 'applied' : 'failed');
      }
      final assistantMessage = ChatMessage()
        ..uuid = messageUuid
        ..role = 'assistant'
        ..text = result.reply
        ..createdAt = DateTime.now()
        ..contextRef = contextRef;
      await chatRepository.appendMessage(assistantMessage);
      if (!mounted || generation != _generation) {
        await chatRepository.deleteMessage(assistantMessage);
        return;
      }
      setState(() {
        _messages = [..._messages, assistantMessage];
        _sending = false;
      });
      _scrollToBottom();
      unawaited(_refreshChatQuota());
      if (_pathSnapshots.containsKey(messageUuid)) {
        invalidateHomeProviders(ref);
        _showPathEditSnackBar(assistantMessage, pathEdit!);
      }
    } on BuiltInChatQuotaExceededException {
      if (!mounted || generation != _generation) return;
      setState(() => _sending = false);
      final unlocked = await showBuiltInChatQuotaDialog(context);
      unawaited(_refreshChatQuota());
      if (unlocked && mounted) {
        setState(() => _sending = true);
        await _requestReply(text, chatRepository);
      }
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() => _sending = false);
      await showAppErrorDialog(context, e);
    }
  }

  /// Chip confirm — shared with Home via [ProposedActionRunner].
  Future<void> _confirmAction(ChatProposedAction action) async {
    if (!mounted) return;
    await ProposedActionRunner.run(context, ref, action);
  }

  /// Locks in one in-chat quiz answer and persists it into the message's
  /// contextRef (replacing only the quiz key, everything else untouched).
  Future<void> _answerInlineQuiz(ChatMessage message, int questionIndex, int option) async {
    final quiz = ChatInlineQuiz.fromContextRef(message.contextRef);
    if (quiz == null) return;
    final updated = quiz.withAnswer(questionIndex, option);
    if (identical(updated, quiz)) return;
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(message.contextRef!) as Map);
    } catch (_) {
      return;
    }
    data[ChatInlineQuiz.contextKey] = updated.toJson();
    setState(() => message.contextRef = jsonEncode(data));
    await ref.read(chatRepositoryProvider).saveMessage(message);
    if (updated.isComplete) _scrollToBottom();
  }

  /// Undo snapshots for path edits applied this session, by message uuid.
  /// In memory only: after a restart the card shows what changed but can no
  /// longer undo it (the learner can ask the agent to change it back).
  final Map<String, PathSnapshot> _pathSnapshots = {};

  static String? _withPathEditStatus(String? contextRef, String status) {
    if (contextRef == null) return null;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(contextRef) as Map);
      data[_pathEditStatusKey] = status;
      return jsonEncode(data);
    } catch (_) {
      return contextRef;
    }
  }

  void _showPathEditSnackBar(ChatMessage message, PathEditPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Learning path updated: ${plan.describe()}'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: 'Undo', onPressed: () => _undoPathEdit(message)),
      ),
    );
  }

  Future<void> _undoPathEdit(ChatMessage message) async {
    final snapshot = _pathSnapshots.remove(message.uuid);
    if (snapshot == null) return;
    await LearningPlanEditor(ref.read(learnerRepositoryProvider)).restore(snapshot);
    if (!mounted) return;
    setState(() => message.contextRef = _withPathEditStatus(message.contextRef, 'undone'));
    await ref.read(chatRepositoryProvider).saveMessage(message);
    if (!mounted) return;
    invalidateHomeProviders(ref);
  }

  Future<void> _copyReply(ChatMessage message) async {
    await Clipboard.setData(ClipboardData(text: message.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied'), duration: Duration(seconds: 2)),
    );
  }

  /// Follow-up turns offered by a completed in-chat quiz card. Null while a
  /// reply is in flight so the card never queues a second request.
  _InlineQuizFollowUps? _quizFollowUps(ChatInlineQuiz quiz) {
    if (_sending) return null;
    final on = quiz.topic.isEmpty ? '' : ' on ${quiz.topic}';
    return _InlineQuizFollowUps(
      explainMistakes: () => _send(
        quickReply: 'Explain the questions I got wrong in that quiz$on.',
      ),
      anotherRound: () => _send(
        quickReply: quiz.score == quiz.questions.length
            ? 'Quiz me again$on with harder questions.'
            : 'Quiz me again$on, focusing on what I missed.',
      ),
      fullQuiz: quiz.topic.isEmpty
          ? null
          : () => _confirmAction(ChatProposedAction.quiz(topic: quiz.topic, questionCount: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personalization = ref.watch(personalizationProvider).asData?.value;
    final domainProfile = LearningDomains.profileForGoal([
      personalization?.goalContextLabel ?? '',
      ...?personalization?.primaryTopics,
    ]);

    // Chat has no "attached" success UI of its own (ChatGenerationStatus
    // only ever shows the running state) — as soon as a job started from
    // here finishes, hand off immediately so the global GenerationReadyBanner
    // picks it up even if the learner never navigates away from chat.
    ref.listen(generationJobServiceProvider, (previous, next) {
      if (previous?.isRunning == true && !next.isRunning && next.uiAttached) {
        next.continueInBackground();
      }
    });

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
                      ? _EmptyState(
                          theme: theme,
                          starters: domainProfile.chatStarters,
                          onStarter: (text) => _send(quickReply: text),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_sending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _messages.length) {
                              return const _TypingBubble();
                            }
                            final message = _messages[index];
                            final isLatestUser = message.role == 'user' &&
                                !_messages.skip(index + 1).any((m) => m.role == 'user');
                            final canAct = message.role == 'user' && !_sending;
                            final isLatest = index == _messages.length - 1;
                            return _ChatBubble(
                              message: message,
                              theme: theme,
                              onConfirmAction: _confirmAction,
                              onEdit: canAct && isLatestUser ? () => _edit(message) : null,
                              onResend: canAct && isLatestUser ? () => _resend(message) : null,
                              onLongPress: canAct ? () => _openTurnActions(message) : null,
                              onCopy: () => _copyReply(message),
                              onSpeak: () => _toggleSpeak(message),
                              speaking: _speakingUuid == message.uuid,
                              onUndoPathEdit: _pathSnapshots.containsKey(message.uuid)
                                  ? () => _undoPathEdit(message)
                                  : null,
                              onAnswerQuiz: (q, o) => _answerInlineQuiz(message, q, o),
                              quizFollowUps: _quizFollowUps,
                              // Quick replies only make sense as the next
                              // turn, so only the newest reply shows them.
                              onSuggestion: isLatest && !_sending
                                  ? (text) => _send(quickReply: text)
                                  : null,
                            );
                          },
                        ),
            ),
            const ChatGenerationStatus(),
            _ComposerBar(
              controller: _controller,
              enabled: !_sending,
              sending: _sending,
              attachmentLabel: _attachmentLabel,
              onSend: _send,
              onStop: _stop,
              onAdd: _openAddMenu,
              onMic: _speechAvailable ? _toggleVoice : null,
              recording: _recording,
              busyAttaching: _readingPhoto,
              // An empty thread has nothing to quiz on yet, so fall back to
              // the learner's own goal and recent mistakes.
              onQuizMe: () => _send(
                quickReply: _messages.isEmpty
                    ? 'Quiz me on my current goal, focusing on what I tend to get wrong.'
                    : 'Quiz me on what we just discussed.',
              ),
              onClearAttachment: () => setState(() {
                _attachmentText = null;
                _attachmentLabel = null;
              }),
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
  const _EmptyState({required this.theme, required this.onStarter, required this.starters});

  final ThemeData theme;
  final ValueChanged<String> onStarter;

  /// From the learner's [LearningDomainProfile] (fitness, coding, art, ...).
  final List<String> starters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
            const SizedBox(height: 20),
            _SuggestionChips(suggestions: starters, onTap: onStarter, centered: true),
          ],
        ),
      ),
    );
  }
}

/// Footer callbacks for a completed in-chat quiz card; any may be null.
class _InlineQuizFollowUps {
  const _InlineQuizFollowUps({this.explainMistakes, this.anotherRound, this.fullQuiz});

  final VoidCallback? explainMistakes;
  final VoidCallback? anotherRound;
  final VoidCallback? fullQuiz;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.theme,
    required this.onConfirmAction,
    required this.onCopy,
    required this.onAnswerQuiz,
    required this.quizFollowUps,
    this.onEdit,
    this.onResend,
    this.onLongPress,
    this.onSuggestion,
    this.onUndoPathEdit,
    this.onSpeak,
    this.speaking = false,
  });

  final VoidCallback? onUndoPathEdit;
  final VoidCallback? onSpeak;
  final bool speaking;

  final ChatMessage message;
  final ThemeData theme;
  final Future<void> Function(ChatProposedAction action) onConfirmAction;
  final VoidCallback onCopy;
  final void Function(int questionIndex, int option) onAnswerQuiz;
  final _InlineQuizFollowUps? Function(ChatInlineQuiz quiz) quizFollowUps;
  final VoidCallback? onEdit;
  final VoidCallback? onResend;
  final VoidCallback? onLongPress;
  final ValueChanged<String>? onSuggestion;

  Map<String, dynamic>? get _decodedContext {
    final raw = message.contextRef;
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }

  ChatProposedAction? get _decodedAction {
    final json = _decodedContext;
    if (json == null) return null;
    return ChatProposedAction.fromJson(json);
  }

  /// Reads the same persisted JSON's separate "sources" key, ignored by
  /// [ChatProposedAction.fromJson] itself. Real links gathered before the
  /// model call (see `ChatService.sendMessage`), never anything the model
  /// wrote itself.
  List<ChatSourceSuggestion> get _decodedSources {
    final json = _decodedContext;
    final raw = json?['sources'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => ChatSourceSuggestion.fromJson(Map<String, dynamic>.from(m)))
        .whereType<ChatSourceSuggestion>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bubbleColor =
        isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final action = isUser ? null : _decodedAction;
    final sources = isUser ? const <ChatSourceSuggestion>[] : _decodedSources;
    final turn = isUser ? ChatTurnText.parse(message.text) : null;
    final inlineQuiz = isUser ? null : ChatInlineQuiz.fromJson(_decodedContext?[ChatInlineQuiz.contextKey]);
    final suggestions = isUser || onSuggestion == null
        ? const <String>[]
        : ChatSuggestedReplies.normalize(_decodedContext?[ChatSuggestedReplies.contextKey]);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.35);
    final pathEdit = isUser ? null : PathEditPlan.fromJson(_decodedContext?[ChatReplyResult.pathEditKey]);
    final pathEditStatus = _decodedContext?[_pathEditStatusKey]?.toString() ?? 'applied';

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          if (turn?.attachmentLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AttachmentPill(
                label: turn!.attachmentLabel!,
                color: textColor,
              ),
            ),
          if (isUser)
            Text(turn?.displayQuestion ?? message.text, style: bodyStyle)
          else
            MarkdownBody(
              data: message.text,
              selectable: true,
              softLineBreak: true,
              onTapLink: (text, href, title) {
                final uri = href == null ? null : Uri.tryParse(href);
                if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: bodyStyle,
                listBullet: bodyStyle,
                code: bodyStyle?.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
            ),
          if (action != null)
            ChatActionChip(action: action, onConfirm: () => onConfirmAction(action)),
          for (final source in sources) _ChatSourceLink(source: source, textColor: textColor),
        ],
      ),
    );

    final quietStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: Size.zero,
      foregroundColor: theme.colorScheme.onSurfaceVariant,
      textStyle: theme.textTheme.labelSmall,
    );
    final userActions = onEdit == null && onResend == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                TextButton.icon(
                  style: quietStyle,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                ),
              if (onResend != null)
                TextButton.icon(
                  style: quietStyle,
                  onPressed: onResend,
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Resend'),
                ),
            ],
          );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: isUser
            ? GestureDetector(
                onLongPress: onLongPress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    bubble,
                    ?userActions,
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ChatAvatar(radius: 14),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        bubble,
                        if (pathEdit != null)
                          _PathEditCard(
                            plan: pathEdit,
                            status: pathEditStatus,
                            onUndo: onUndoPathEdit,
                          ),
                        if (inlineQuiz != null)
                          ConstrainedBox(
                            // A touch wider than a text bubble: options need
                            // room to stay on one line.
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.84,
                            ),
                            child: _buildQuizCard(inlineQuiz),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              style: quietStyle,
                              onPressed: onCopy,
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: const Text('Copy'),
                            ),
                            if (onSpeak != null)
                              TextButton.icon(
                                style: quietStyle,
                                onPressed: onSpeak,
                                icon: Icon(
                                  speaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                                  size: 14,
                                ),
                                label: Text(speaking ? 'Stop' : 'Listen'),
                              ),
                          ],
                        ),
                        if (suggestions.isNotEmpty)
                          _SuggestionChips(suggestions: suggestions, onTap: onSuggestion!),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuizCard(ChatInlineQuiz quiz) {
    final followUps = quiz.isComplete ? quizFollowUps(quiz) : null;
    return ChatInlineQuizCard(
      quiz: quiz,
      onAnswer: onAnswerQuiz,
      onExplainMistakes: followUps?.explainMistakes,
      onAnotherRound: followUps?.anotherRound,
      onFullQuiz: followUps?.fullQuiz,
    );
  }
}

/// Shows what the agent changed in the learner's path, under its reply.
class _PathEditCard extends StatelessWidget {
  const _PathEditCard({required this.plan, required this.status, this.onUndo});

  final PathEditPlan plan;

  /// applied | failed | undone
  final String status;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (IconData icon, Color color, String headline) = switch (status) {
      'failed' => (Icons.error_outline_rounded, scheme.error, "Couldn't update your learning path"),
      'undone' => (Icons.undo_rounded, scheme.onSurfaceVariant, 'Change undone'),
      _ => (Icons.auto_fix_high_rounded, scheme.primary, 'Learning path updated'),
    };
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: theme.textTheme.labelLarge?.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(
                  status == 'failed'
                      ? 'No active path, or the module numbers no longer match.'
                      : plan.describe(),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (status == 'applied' && onUndo != null)
            TextButton(onPressed: onUndo, child: const Text('Undo')),
        ],
      ),
    );
  }
}

/// Quick-reply chips under the newest assistant reply; a tap sends the chip
/// text as the learner's next turn.
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.suggestions, required this.onTap, this.centered = false});

  final List<String> suggestions;
  final ValueChanged<String> onTap;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        alignment: centered ? WrapAlignment.center : WrapAlignment.start,
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final s in suggestions)
            ActionChip(
              label: Text(s),
              labelStyle: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
              backgroundColor: theme.colorScheme.surface,
              shape: const StadiumBorder(),
              visualDensity: VisualDensity.compact,
              onPressed: () => onTap(s),
            ),
        ],
      ),
    );
  }
}

/// A real, verified public-source link (Wikipedia, arXiv, etc.) shown below
/// a reply, opened externally on tap. See `ChatService.sendMessage`: these
/// come straight from `OpenKnowledgeService`, never from the model.
class _ChatSourceLink extends StatelessWidget {
  const _ChatSourceLink({required this.source, required this.textColor});

  final ChatSourceSuggestion source;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          final uri = Uri.tryParse(source.url);
          if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 14, color: textColor.withValues(alpha: 0.75)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                source.source.isNotEmpty ? '${source.source}: ${source.title}' : source.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.85),
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cycles through short "what's happening" phrases instead of a bare spinner,
/// so a slow reply reads as progress rather than a stall (this and the
/// concurrent-fetch changes in ChatService together address "chat feels too
/// slow, show what's happening").
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> {
  static const _phrases = [
    'Reading your message…',
    'Checking your library and sources…',
    'Thinking it through…',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _ChatAvatar(radius: 14),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _phrases[_index],
                      key: ValueKey(_index),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
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
    required this.sending,
    required this.onSend,
    required this.onStop,
    required this.onAdd,
    required this.onQuizMe,
    this.onMic,
    this.recording = false,
    this.busyAttaching = false,
    this.attachmentLabel,
    this.onClearAttachment,
  });

  final VoidCallback onAdd;

  /// Voice input; null hides nothing but disables the button (no speech key).
  final VoidCallback? onMic;
  final bool recording;

  /// A photo is being read by the vision model.
  final bool busyAttaching;

  /// Shared box for every toolbar button so they sit on one centre line.
  static const double _toolSize = 40;

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback onQuizMe;
  final String? attachmentLabel;
  final VoidCallback? onClearAttachment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiet = IconButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      fixedSize: const Size.square(_toolSize),
      minimumSize: const Size.square(_toolSize),
      padding: EdgeInsets.zero,
      foregroundColor: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (attachmentLabel != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 4, 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          attachmentLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        visualDensity: VisualDensity.compact,
                        onPressed: onClearAttachment,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              // Two rows (text on top, tools below), the layout ChatGPT and
              // Claude use: the input gets the full width, and every tool
              // button shares one fixed 40x40 box so they line up on a single
              // centre line no matter how tall the text field grows.
              TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: InputDecoration(
                  hintText: sending ? 'Replying…' : 'Ask anything, or say "quiz me"',
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // One "+" for every way to give the tutor material (file,
                  // scan, photo question) keeps the bar to four controls.
                  IconButton(
                    tooltip: 'Add a file, scan, or photo',
                    style: quiet,
                    onPressed: enabled && !busyAttaching ? onAdd : null,
                    icon: busyAttaching
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline_rounded, size: 24),
                  ),
                  IconButton(
                    tooltip: recording ? 'Stop and transcribe' : 'Speak your question',
                    style: recording
                        ? IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            fixedSize: const Size.square(_toolSize),
                            minimumSize: const Size.square(_toolSize),
                            padding: EdgeInsets.zero,
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.onErrorContainer,
                          )
                        : quiet,
                    onPressed: (enabled || recording) && onMic != null ? onMic : null,
                    icon: Icon(recording ? Icons.stop_rounded : Icons.mic_none_rounded, size: 22),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: _toolSize,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: enabled ? onQuizMe : null,
                      icon: const Icon(Icons.quiz_outlined, size: 18),
                      label: const Text('Quiz me'),
                    ),
                  ),
                  const Spacer(),
                  IconButton.filled(
                    tooltip: sending ? 'Stop' : 'Send',
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fixedSize: const Size.square(_toolSize),
                      minimumSize: const Size.square(_toolSize),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: sending ? onStop : onSend,
                    icon: Icon(sending ? Icons.stop_rounded : Icons.arrow_upward_rounded, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentPill extends StatelessWidget {
  const _AttachmentPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file_rounded, size: 14, color: color),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.5),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({required this.initial});

  final String initial;

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit message', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Your message',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _controller.text),
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
