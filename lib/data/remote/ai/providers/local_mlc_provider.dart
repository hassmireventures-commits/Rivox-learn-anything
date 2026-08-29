import 'package:flutter/services.dart';

import '../../../../core/error/app_exception.dart';
import '../../../local_llm/local_llm_channel.dart';
import '../ai_output_gate.dart';
import '../ai_provider.dart';
import '../models/generated_quiz.dart';
import '../models/quiz_generation_request.dart';
import '../prompt_builder.dart';
import '../quiz_json_parser.dart';

/// On-device quiz generation via MLC (MethodChannel → LocalLLMEngine).
class LocalMlcProvider implements AiProvider {
  LocalMlcProvider({LocalLlmChannel? channel})
      : _channel = channel ?? LocalLlmChannel();

  final LocalLlmChannel _channel;

  static const _quizSystemPrompt =
      'You are a quiz generator. Respond with a single valid JSON object only. '
      'No markdown, no code fences, no commentary. '
      'The questions array length must exactly match the Count in the user message — never add extra questions. '
      'Each explanation must match the option at correctIndex. '
      'Do not generate harmful content.';

  @override
  Future<GeneratedQuiz> generateQuiz(QuizGenerationRequest request) async {
    final ram = await _channel.checkRam();
    if (!ram.ok) {
      throw const ProviderUnavailableException(
        'This device does not have enough RAM for the on-device LLM (needs about 6 GB). '
        'Switch to a cloud provider in Settings → AI Providers.',
      );
    }
    final ready = await _channel.isModelReady();
    if (!ready) {
      throw const ProviderUnavailableException(
        'On-device model is not downloaded yet. Open Settings → AI Providers and finish setup.',
      );
    }

    try {
      final userPrompt = await PromptBuilder.build(request);
      var content = await _channel.generate(
        prompt: AiOutputGate.adaptUserPrompt(userPrompt, 'local-mlc'),
        systemPrompt: AiOutputGate.adaptSystemPrompt(_quizSystemPrompt, 'local-mlc'),
      );
      if (AiOutputGate.needsStrictRetry(
        content,
        validateContent: (text) =>
            QuizJsonParser.accepts(text, expectedCount: request.questionCount),
      )) {
        content = await _channel.generate(
          prompt: AiOutputGate.adaptUserPrompt(userPrompt, 'local-mlc'),
          systemPrompt: AiOutputGate.adaptSystemPrompt(
            AiOutputGate.strictRetrySystemPrompt(_quizSystemPrompt),
            'local-mlc',
          ),
        );
      }
      final json = AiOutputGate.requireJsonOutput(content);
      return QuizJsonParser.parse(json, expectedCount: request.questionCount);
    } on PlatformException catch (e) {
      throw ProviderUnavailableException(e.message ?? 'Local LLM failed.');
    }
  }
}
