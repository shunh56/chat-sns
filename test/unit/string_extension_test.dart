import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/extenstions/string_extenstion.dart';

void main() {
  group('StringExtension', () {
    group('Email Validation', () {
      test('should validate correct email addresses', () {
        expect('test@example.com'.isEmail, true);
        expect('user.name@domain.co.jp'.isEmail, true);
        expect('valid@test.org'.isEmail, true);
      });

      test('should reject invalid email addresses', () {
        expect('invalid-email'.isEmail, false);
        expect('test@'.isEmail, false);
        expect('@domain.com'.isEmail, false);
        expect('test.domain.com'.isEmail, false);
      });
    });

    group('Username Validation', () {
      test('should validate correct usernames', () {
        expect('user123'.isUsername, true);
        expect('test_user'.isUsername, true);
        expect('valid.name'.isUsername, true);
      });

      test('should reject invalid usernames', () {
        expect('short'.isUsername, false); // too short
        expect('toolongusername123456'.isUsername, false); // too long
        expect('_invalid'.isUsername, false); // starts with underscore
        expect('invalid_'.isUsername, false); // ends with underscore
      });
    });

    group('Username Error Messages', () {
      test('should return null for valid usernames', () {
        expect('validuser'.usernameError, null);
        expect('test123'.usernameError, null);
      });

      test('should return length error for short/long usernames', () {
        expect('short'.usernameError, "ユーザー名は6～16文字で入力してください。");
        expect('toolongusername123456'.usernameError, "ユーザー名は6～16文字で入力してください。");
      });

      test('should return format error for invalid usernames', () {
        expect('_invalid'.usernameError, "そのユーザー名は使用できません。");
        expect('invalid__user'.usernameError, "そのユーザー名は使用できません。");
      });

      test('should return null for empty string', () {
        expect(''.usernameError, null);
      });
    });
  });
}
