import 'package:ai_quiz_app/core/services/built_in_ai_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuiltInAiRouter', () {
    test('modelsToTry puts known-good primary first regardless of stored model', () {
      final models = BuiltInAiRouter.modelsToTry('nvidia/nemotron-3-nano-30b-a3b');
      expect(models.first, BuiltInAiRouter.primaryModel);
      expect(models, contains('nvidia/nemotron-3-nano-30b-a3b'));
      expect(models.toSet().length, models.length);
    });

    test('isRetryableModelError detects 410 and EOL body', () {
      final e410 = DioException(
        requestOptions: RequestOptions(path: '/chat/completions'),
        response: Response(
          requestOptions: RequestOptions(path: '/chat/completions'),
          statusCode: 410,
          data: {
            'detail': "The model has reached its end of life",
          },
        ),
        type: DioExceptionType.badResponse,
      );
      expect(BuiltInAiRouter.isRetryableModelError(e410), isTrue);

      final e401 = DioException(
        requestOptions: RequestOptions(path: '/chat/completions'),
        response: Response(
          requestOptions: RequestOptions(path: '/chat/completions'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      expect(BuiltInAiRouter.isRetryableModelError(e401), isFalse);
    });
  });
}
