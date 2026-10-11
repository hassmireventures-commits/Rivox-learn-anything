import 'package:ai_quiz_app/data/remote/auth/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  test('a dismissed account sheet stays quiet', () {
    expect(
      googleSignInWasUserDismiss(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'User canceled the selector',
        ),
      ),
      isTrue,
    );
  });

  test('a canceled result after choosing an account is shown', () {
    expect(
      googleSignInWasUserDismiss(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: '[16] Cancelled by user.',
        ),
      ),
      isFalse,
    );
  });
}
