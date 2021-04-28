import 'dart:convert';

import 'package:flutter_reddit/src/const.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';

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

  // MODIFIED
  Future<AccessTokenResponse> refreshToken(String refreshToken,
      {httpClient, required String clientId, String? clientSecret}) async {
    final Map params = getRefreshUrlParams(refreshToken: refreshToken);

    var response = await _performAuthorizedRequest(
        url: _getRefreshUrl(),
        clientId: clientId,
        clientSecret: clientSecret,
        params: params,
        httpClient: httpClient,
        headers: {
          'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:'))
        });

    return http2TokenResponse(response);
  }

  // COPIED
  Future<http.Response> _performAuthorizedRequest(
      {required String url,
      required String clientId,
      String? clientSecret,
      Map? params,
      Map<String, String>? headers,
      httpClient}) async {
    httpClient ??= http.Client();

    headers ??= {};
    params ??= {};

    //If a client secret has been specified, it will be sent in the "Authorization" header instead of a body parameter...
    if (clientSecret == null || clientSecret.isEmpty) {
      if (clientId.isNotEmpty) {
        params['client_id'] = clientId;
      }
    } else {
      switch (credentialsLocation) {
        case CredentialsLocation.HEADER:
          headers.addAll(getAuthorizationHeader(
            clientId: clientId,
            clientSecret: clientSecret,
          ));
          break;
        case CredentialsLocation.BODY:
          params['client_id'] = clientId;
          params['client_secret'] = clientSecret;
          break;
      }
    }

    var response =
        await httpClient.post(Uri.parse(url), body: params, headers: headers);

    return response;
  }

  // COPIED
  String _getRefreshUrl() {
    return refreshUrl ?? tokenUrl;
  }
}
