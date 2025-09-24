// Flutter imports:
import 'package:flutter/foundation.dart';

// ignore: non_constant_identifier_names
void DebugPrint(dynamic obj) {
  if (kDebugMode) {
    print("debug : $obj");
  }
}
