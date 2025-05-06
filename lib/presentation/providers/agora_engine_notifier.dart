import 'dart:convert';

import 'package:app/core/utils/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final agoraEngineNotifierProvider = Provider((ref) => AgoraEngineNotifier());

class AgoraEngineNotifier {
  Future<String> fetchToken(int uid, String channelName) async {
    String url =
        '$serverUrl/rtc/$channelName/${tokenRole.toString()}/uid/${uid.toString()}?expiry=${tokenExpireTime.toString()}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      return newToken;
    } else {
      return throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }
}
