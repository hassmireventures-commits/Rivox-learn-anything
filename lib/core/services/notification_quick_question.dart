import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/models/question.dart';

/// One multiple-choice question small enough to answer from a notification:
/// at most three options (Android shows at most three action buttons), and
/// no question that needs a passage, chart, or spoken answer.
class QuickQuestion {
  const QuickQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
    this.sourceId = '',
  });

  static const int maxOptions = 3;
  static const int maxQuestionLength = 220;
  static const int maxOptionLength = 90;
  static const String payloadPrefix = 'qa:';
  static const List<String> letters = ['A', 'B', 'C'];

  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  /// uuid of the source [Question], for the answer log.
  final String sourceId;

  /// Builds a notification-sized question from a saved quiz question, or
  /// null when it does not fit. Keeps the correct option plus up to two
  /// distractors, shuffled with [random].
  static QuickQuestion? fromQuestion(Question q, {Random? random}) {
    final type = q.type.toLowerCase();
    if (type == 'short_answer' || type == 'behavioral' || type == 'open') return null;
    if ((q.stimulusJson ?? '').trim().isNotEmpty) return null;
    final text = q.text.trim();
    if (text.isEmpty || text.length > maxQuestionLength) return null;
    List<String> options;
    try {
      options = (jsonDecode(q.optionsJson) as List).map((o) => o.toString().trim()).toList();
    } catch (_) {
      return null;
    }
    if (options.length < 2 || q.correctIndex < 0 || q.correctIndex >= options.length) return null;
    if (options.any((o) => o.isEmpty || o.length > maxOptionLength || o == '__open__')) return null;

    final rng = random ?? Random();
    final correct = options[q.correctIndex];
    final distractors = [
      for (var i = 0; i < options.length; i++)
        if (i != q.correctIndex) options[i],
    ]..shuffle(rng);
    final picked = [correct, ...distractors.take(maxOptions - 1)]..shuffle(rng);
    return QuickQuestion(
      text: text,
      options: picked,
      correctIndex: picked.indexOf(correct),
      explanation: (q.explanation ?? '').trim(),
      sourceId: q.quizUuid,
    );
  }

  /// "A) ...\nB) ..." body under the question.
  String get body {
    final lines = [
      text,
      for (var i = 0; i < options.length; i++) '${letters[i]}) ${options[i]}',
    ];
    return lines.join('\n');
  }

  String toPayload() => payloadPrefix +
      jsonEncode({
        'q': text,
        'o': options,
        'c': correctIndex,
        if (explanation.isNotEmpty) 'e': explanation,
        if (sourceId.isNotEmpty) 's': sourceId,
      });

  static QuickQuestion? fromPayload(String? payload) {
    if (payload == null || !payload.startsWith(payloadPrefix)) return null;
    try {
      final m = jsonDecode(payload.substring(payloadPrefix.length)) as Map;
      final options = (m['o'] as List).map((e) => e.toString()).toList();
      final c = (m['c'] as num).toInt();
      if (c < 0 || c >= options.length) return null;
      return QuickQuestion(
        text: m['q']?.toString() ?? '',
        options: options,
        correctIndex: c,
        explanation: m['e']?.toString() ?? '',
        sourceId: m['s']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static String actionIdFor(int option) => 'qa_$option';

  /// Option index from a tapped action id, or null for anything else.
  static int? optionFromActionId(String? actionId) {
    if (actionId == null || !actionId.startsWith('qa_')) return null;
    return int.tryParse(actionId.substring(3));
  }

  /// Feedback line for the follow-up notification.
  ({bool correct, String title, String body}) grade(int option) {
    final ok = option == correctIndex;
    final answer = '${letters[correctIndex]}) ${options[correctIndex]}';
    final why = explanation.isEmpty ? '' : ' $explanation';
    return (
      correct: ok,
      title: ok ? 'Correct!' : 'Not quite',
      body: ok ? 'Nice recall.$why' : 'The answer is $answer.$why',
    );
  }
}

/// Notification ids for the quick question and its result.
class QuickQuestionIds {
  QuickQuestionIds._();

  /// Scheduled questions use base + day offset (0..[daysAhead]-1).
  static const int base = 6100;
  static const int daysAhead = 3;
  static const int result = 6199;
}

const String kQuickQuestionChannelId = 'quick_question';

/// Grades a tapped answer and replaces the question with the result. Shared
/// by the foreground handler and [quickQuestionBackgroundHandler]. Returns
/// false when [response] is not a quick-question answer.
Future<bool> handleQuickQuestionResponse(
  FlutterLocalNotificationsPlugin plugin,
  NotificationResponse response,
) async {
  final option = QuickQuestion.optionFromActionId(response.actionId);
  final question = QuickQuestion.fromPayload(response.payload);
  if (option == null || question == null) return false;
  final result = question.grade(option);
  if (response.id != null) {
    try {
      await plugin.cancel(id: response.id!);
    } catch (_) {}
  }
  await plugin.show(
    id: QuickQuestionIds.result,
    title: result.title,
    body: result.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        kQuickQuestionChannelId,
        'Quick question',
        channelDescription: 'One question a day you can answer from the notification',
        importance: Importance.defaultImportance,
        styleInformation: BigTextStyleInformation(result.body),
      ),
    ),
    payload: '/dashboard',
  );
  await QuickQuestionLog.append(question: question, option: option, correct: result.correct);
  return true;
}

/// Runs in a background isolate when the app is closed and the learner taps
/// an answer button. Must stay a top-level, entry-point function.
@pragma('vm:entry-point')
Future<void> quickQuestionBackgroundHandler(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await handleQuickQuestionResponse(plugin, response);
}

/// Append-only answer log (a small JSON file, readable from a background
/// isolate without opening the database). Counts toward "answered today"
/// and lets the app re-ask missed ones.
class QuickQuestionLog {
  QuickQuestionLog._();

  static const int maxEntries = 200;

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/quick_question_log.json');
  }

  static Future<List<Map<String, dynamic>>> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> append({
    required QuickQuestion question,
    required int option,
    required bool correct,
  }) async {
    try {
      final entries = await read();
      entries.add({
        'at': DateTime.now().toIso8601String(),
        'q': question.text,
        'correct': correct,
        'picked': question.options[option],
        if (question.sourceId.isNotEmpty) 's': question.sourceId,
      });
      final trimmed = entries.length > maxEntries ? entries.sublist(entries.length - maxEntries) : entries;
      await (await _file()).writeAsString(jsonEncode(trimmed));
    } catch (_) {}
  }

  /// Answered at least one quick question on the calendar day of [now].
  static Future<bool> answeredOn(DateTime now) async {
    final entries = await read();
    return entries.any((e) {
      final at = DateTime.tryParse(e['at']?.toString() ?? '');
      return at != null && at.year == now.year && at.month == now.month && at.day == now.day;
    });
  }
}
