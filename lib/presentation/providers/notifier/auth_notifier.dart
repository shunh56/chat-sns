import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/pages/auth/signup_page.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';

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
        await _ref.read(myAccountNotifierProvider.notifier).initialize();
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
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      // GoogleSignInの初期化を一度だけ行う
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['profile', 'email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        DebugPrint("canceled"); // DebugPrint ではなく debugPrint を使用
        _ref.read(loginProcessProvider.notifier).state = false;
        return "provider_error";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _ref.read(myAccountNotifierProvider.notifier).initialize();
        await Future.delayed(const Duration(seconds: 2));

        return "success";
      } else {
        _ref.read(loginProcessProvider.notifier).state = false;
        return "unknown_error";
      }
    } on FirebaseAuthException catch (e) {
      _ref.read(loginProcessProvider.notifier).state = false;
      DebugPrint("Firebase auth error: ${e.message}");
      showErrorSnackbar(error: e.message ?? "Authentication failed");
      return "firebase_error";
    } catch (e) {
      _ref.read(loginProcessProvider.notifier).state = false;
      DebugPrint("Other auth error: $e");
      showErrorSnackbar(error: "Authentication failed");
      return "unknown_error";
    }
  }
 
 
 /*Future<String> signInWithGoogle() async {
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['profile', 'email'],
      ).signIn();
      if (googleUser == null) {
        DebugPrint("canceled");
        _ref.read(loginProcessProvider.notifier).state = false;
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
        _ref.read(loginProcessProvider.notifier).state = false;
        return "unknown_error";
      }
    } catch (e) {
      _ref.read(loginProcessProvider.notifier).state = false;
      DebugPrint("auth error : $e");
      showErrorSnackbar(error: e);
      return "unknown_error";
    }
  }
  */

  Future<String> signInWithApple() async {
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

      //DebugPrint(appleCredential.familyName);
      //DebugPrint(appleCredential.givenName);
      //DebugPrint(appleCredential.email);
      //DebugPrint(appleCredential.userIdentifier);
      //DebugPrint(appleCredential.identityToken);
      //DebugPrint(appleCredential.authorizationCode);

      final UserCredential user = await _auth.signInWithCredential(credential);

      if (user.user != null) {
        await _ref.read(myAccountNotifierProvider.notifier).initialize();
        await Future.delayed(const Duration(seconds: 2));
        return "success";
      } else {
        _ref.read(loginProcessProvider.notifier).state = false;
        return "unknown_error";
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      _ref.read(loginProcessProvider.notifier).state = false;
      DebugPrint("Apple Auth Error : $e");
      return "apple_error";
    } catch (e) {
      _ref.read(loginProcessProvider.notifier).state = false;
      DebugPrint("error : $e");
      showErrorSnackbar(error: e);
      return "unknown_error";
    }
  }

  Future<String> signInWithTwitter() async {
    _ref.read(loginProcessProvider.notifier).state = true;
    try {
      final twitterLogin = TwitterLogin(
        apiKey: 'DaYfVx0PIBQNkx0eoPkAy7Djy',
        apiSecretKey: '7OUt0Q5MdT2VRGhsYTVLHmG9ojZ5haXMtWa58SJo0EZbkonR9j',
        redirectURI: 'twitterauth://',
        //redirectURI: 'https://chat-sns-project.firebaseapp.com/__/auth/handler',

        // apiKey: 'ZkxJOFkwNUFzZmhXWk5XRGh3eHQ6MTpjaQ', //clientId,
        // apiSecretKey:
        //     '_nv4dTVcHm7sVjP_Nr4MTaMpTza_nE_yc0jJ80FnItPl7YbSDW', //clientSecret

        //apiKey: 'XULhWK4he0GOCeUChOSzJVD3a',
        //apiSecretKey: '3bQmRlnJB7tOFhezeCbTbcI0bNRUzhRc7EC8PmXVbf9aHQYBZN',

        // apiKey: '1104908866695782401-2JjKlWTG8TF9ECGLJtl65Gx8f9DWxI',
        // apiSecretKey: '2fsYTLpUGzadkKGYRJgHRWwMeOdmmImcEKSSYkBA54DNv',
      );

      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        final accessToken = authResult.authToken;
        final secret = authResult.authTokenSecret;
        DebugPrint("accesstoken : $accessToken");
        DebugPrint("secret : $secret");
        if (accessToken == null || secret == null) {
          DebugPrint("Token or secret is null");
          return "token_error";
        }

        final credential = TwitterAuthProvider.credential(
          accessToken: accessToken,
          secret: secret,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          return "success";
        } else {
          return "unknown_error";
        }
      } else if (authResult.status == TwitterLoginStatus.cancelledByUser) {
        _ref.read(loginProcessProvider.notifier).state = false;
        DebugPrint("User cancelled the login process");
        return "cancelled_by_user";
      } else if (authResult.status == TwitterLoginStatus.error) {
        _ref.read(loginProcessProvider.notifier).state = false;
        DebugPrint("Error message: ${authResult.errorMessage}");
        return "error: ${authResult.errorMessage}";
      } else {
        _ref.read(loginProcessProvider.notifier).state = false;
        DebugPrint("Unknown error occurred during login");
        return "unknown_error";
      }
    } catch (e) {
      _ref.read(loginProcessProvider.notifier).state = false;
      DebugPrint("Twitter login error: $e");
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

  resetPassword() {
    String email = _ref.read(emailInputTextProvider);
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return "email_error";
    }
    try {
      _auth.sendPasswordResetEmail(email: email);
      showMessage("リセットのメールを送信しました。");
      return "success";
    } catch (e) {
      return "unkown_error";
    }
  }

  signout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _ref.read(myAccountNotifierProvider.notifier).onSignOut();
    await Future.delayed(const Duration(milliseconds: 100));
    _auth.signOut();
  }
}
