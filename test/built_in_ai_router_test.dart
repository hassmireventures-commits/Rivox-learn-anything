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

      final timedOut = DioException(
        requestOptions: RequestOptions(path: '/chat/completions'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(BuiltInAiRouter.isRetryableModelError(timedOut), isTrue);

      final opaque = DioException(
        requestOptions: RequestOptions(path: '/chat/completions'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/chat/completions'),
          statusCode: 400,
          data: {'error': 'The model is temporarily unavailable'},
        ),
      );
      expect(BuiltInAiRouter.isRetryableModelError(opaque), isTrue);
    });

    test('withModelFallback continues after an opaque model failure', () async {
      final tried = <String>[];
      final result = await BuiltInAiRouter.withModelFallback<String>(
        configuredModel: BuiltInAiRouter.primaryModel,
        attempt: (model) async {
          tried.add(model);
          if (tried.length == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: '/chat/completions'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/chat/completions'),
                statusCode: 400,
                data: {'error': 'The model is temporarily unavailable'},
              ),
            );
          }
          return 'ok';
        },
      );
      expect(result, 'ok');
      expect(tried.length, greaterThan(1));
    });
  });
}
