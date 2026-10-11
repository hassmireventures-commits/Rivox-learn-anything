/// Splits a stored user turn into the question shown in the bubble and an
/// optional attachment. The model still receives [compose], which keeps the
/// file text. The bubble does not.
class ChatTurnText {
  const ChatTurnText({
    required this.question,
    this.attachmentLabel,
    this.attachmentBody,
  });

  static const defaultQuestion = 'Explain this and ask me about the important parts.';

  final String question;
  final String? attachmentLabel;
  final String? attachmentBody;

  bool get hasAttachment =>
      attachmentLabel != null &&
      attachmentLabel!.isNotEmpty &&
      attachmentBody != null &&
      attachmentBody!.isNotEmpty;

  /// Question line for the bubble. Falls back to the file name when the
  /// learner attached something and did not type a question.
  String get displayQuestion {
    final typed = question.trim();
    if (typed.isNotEmpty) return typed;
    return attachmentLabel ?? '';
  }

  String compose() {
    if (!hasAttachment) return question.trim();
    final typed = question.trim().isEmpty ? defaultQuestion : question.trim();
    return 'Attached $attachmentLabel:\n$attachmentBody\n\n$typed';
  }

  static ChatTurnText parse(String text) {
    const prefix = 'Attached ';
    if (!text.startsWith(prefix)) {
      return ChatTurnText(question: text);
    }
    final headerEnd = text.indexOf(':\n');
    if (headerEnd <= prefix.length) {
      return ChatTurnText(question: text);
    }
    final label = text.substring(prefix.length, headerEnd).trim();
    final rest = text.substring(headerEnd + 2);
    final split = rest.lastIndexOf('\n\n');
    if (label.isEmpty || split < 0) {
      return ChatTurnText(question: text);
    }
    return ChatTurnText(
      question: rest.substring(split + 2),
      attachmentLabel: label,
      attachmentBody: rest.substring(0, split),
    );
  }
}
