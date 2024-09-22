import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/pages/auth/signup_page.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      showMessage("予期せぬエラーが発生しました。");
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
}
