import 'package:flutter_reddit/src/const.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:uuid/uuid.dart';
// ignore: implementation_imports
import 'package:oauth2_client/src/token_storage.dart';

class RedditOAuthClient extends OAuth2Client {
  final TokenStorage storage;
  RedditOAuthClient({
    required String redirectUri,
    required String customUriScheme,
    required this.storage,
  }) : super(
          authorizeUrl: AUTHORIZE_URL,
          tokenUrl: TOKEN_URL,
          redirectUri: redirectUri,
          customUriScheme: customUriScheme,
        );

  Future<AccessTokenResponse> getTokenWithAppOnlyFlow() async {
    final deviceId = await _getDeviceId();

    return AccessTokenResponse.fromMap({});
  }

  Future<String> _getDeviceId() async {
    final token = await storage.storage.read('deviceId');
    if (token != null) {
      return token;
    } else {
      print('generated device ID for authentication');
      final token = Uuid().v1();
      storage.storage.write('deviceId', token);
      return token;
    }
  }
}
