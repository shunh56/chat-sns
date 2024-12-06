// Flutter imports:
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

const String agoraId = "828592cf9c2b4a31b5e083a7090a19ad";

String serverUrl = "https://agora-token-service-production-6c7e.up.railway.app";
int tokenRole = 1;
int tokenExpireTime = 45;
//double earningRate = 0.7;
bool isTokenExpiring = false;

String APP_STORE_URL = "https://apps.apple.com/jp/app/blank/id6737684833";
String PLAY_STORE_URL = "";
