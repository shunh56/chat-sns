import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/pages/auth/signup_page.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final authNotifierProvider = Provider(
  (ref) => AuthNotifier(
    ref,
    ref.watch(authProvider),
  ),
);

class AuthNotifier {
  AuthNotifier(this._ref, this._auth);
  final Ref _ref;
  final FirebaseAuth _auth;

  Future<String> signIn() async {
    String email = _ref.read(emailInputTextProvider);
    String password = _ref.read(passwordInputTextProvider);

    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return "email_error";
    }
    if (password.length < 10) {
      return "password_error";
    }
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      UserCredential? user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        return "unknown_error";
      }
    } catch (e) {
      DebugPrint("auth error : $e");
      showErrorSnackbar(error: e);
      return "unknown_error";
    }
  }

  Future<String> signInWithGoogle() async {
    //debugPrint('signInWithGoogle()');
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['profile', 'email'],
      ).signIn();

      if (googleUser == null) {
        return "provider_error";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential user = await _auth.signInWithCredential(credential);

      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        return "unknown_error";
      }
    } catch (e) {
      DebugPrint("auth error : $e");
      showErrorSnackbar(error: e);
      return "unknown_error";
    }
  }

  Future<String> signInWithApple() async {
    //debugPrint('signInWithApple()');
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      //debugPrint(appleCredential.familyName);
      //debugPrint(appleCredential.givenName);
      //debugPrint(appleCredential.email);
      //debugPrint(appleCredential.userIdentifier);
      //debugPrint(appleCredential.identityToken);
      //debugPrint(appleCredential.authorizationCode);

      final UserCredential user = await _auth.signInWithCredential(credential);

      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        showMessage("エラーが発生しました。");
        return "user credential not found";
      }
    } catch (e) {
      showMessage("エラーが発生しました。");
      return "unknown_error";
    }
  }

  Future<String> signUp() async {
    String email = _ref.read(emailInputTextProvider);
    String password = _ref.read(passwordInputTextProvider);

    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return "email_error";
    }
    if (password.length < 10) {
      return "password_error";
    }
    _ref.read(signupProcessProvider.notifier).state = true;

    try {
      UserCredential? user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        showMessage("エラーが発生しました。");
        return "unknown_error";
      }
    } catch (e) {
      showMessage("エラーが発生しました。");
      return "unknown_error";
    }
  }

  /* Future<String> signInWithGoogle() async {
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      UserCredential? user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        return "unknown_error";
      }
    } catch (e) {
      //DebugPrint("auth error : $e");
      showErrorSnackbar(error: e);
      return "unknown_error";
    }
  }

  Future<String> signUpWithGoogle() async {
    _ref.read(signupProcessProvider.notifier).state = true;

    try {
      UserCredential? user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        showMessage("エラーが発生しました。");
        return "unknown_error";
      }
    } catch (e) {
      showMessage("エラーが発生しました。");
      return "unknown_error";
    }
  }

  Future<String> signInWithApple() async {
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      UserCredential? user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        return "unknown_error";
      }
    } catch (e) {
      //DebugPrint("auth error : $e");
      showErrorSnackbar(error: e);
      return "unknown_error";
    }
  }

  Future<String> signUpWithApple() async {
    _ref.read(signupProcessProvider.notifier).state = true;

    try {
      UserCredential? user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.user != null) {
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        showMessage("エラーが発生しました。");
        return "unknown_error";
      }
    } catch (e) {
      showMessage("エラーが発生しました。");
      return "unknown_error";
    }
  }

 */
}
