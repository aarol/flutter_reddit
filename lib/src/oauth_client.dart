import 'package:flutter_reddit/src/const.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:random_string/random_string.dart';

class RedditOAuthClient extends OAuth2Client {
  RedditOAuthClient({
    required String redirectUri,
    required String customUriScheme,
  }) : super(
          authorizeUrl: AUTHORIZE_URL,
          tokenUrl: TOKEN_URL,
          redirectUri: redirectUri,
          customUriScheme: customUriScheme,
        );

  Future<AccessTokenResponse> getTokenWithAppOnlyFlow() async {
    return AccessTokenResponse.fromMap({});
  }
}
