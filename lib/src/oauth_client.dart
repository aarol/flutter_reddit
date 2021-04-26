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

  Future<AccessTokenResponse> getTokenWithImplicitGrantFlow({
    required String clientId,
    List<String>? scopes,
    bool enableState = true,
    String? state,
    httpClient,
    webAuthClient,
    Map<String, dynamic>? customParams,
  }) async {
    httpClient ??= http.Client();
    webAuthClient ??= this.webAuthClient;

    if (enableState) state ??= randomAlphaNumeric(25);

    final authorizeUrl = getAuthorizeUrl(
        clientId: clientId,
        responseType: 'code',
        scopes: scopes,
        enableState: enableState,
        state: state,
        redirectUri: redirectUri,
        customParams: customParams);

    // Present the dialog to the user
    final result = await webAuthClient.authenticate(
        url: authorizeUrl, callbackUrlScheme: customUriScheme);

    final fragment = Uri.splitQueryString(Uri.parse(result).fragment);

    if (enableState) {
      final checkState = fragment['state'];
      if (state != checkState) {
        throw Exception(
            '"state" parameter in response doesn\'t correspond to the expected value');
      }
    }

    return AccessTokenResponse.fromMap({
      'access_token': fragment['access_token'],
      'token_type': fragment['token_type'],
      'scope': fragment['scope'] ?? scopes,
      'expires_in': fragment['expires_in'],
      'http_status_code': 200
    });
  }
}
