import 'dart:convert';

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

  Map<String, String> authHeader(String clientId) {
    return {
      'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:')),
    };
  }

  Future<AccessTokenResponse> getTokenWithAppOnlyFlow(
      {required String clientId}) async {
    final deviceId = await _getDeviceId();

    final response = await _performAuthorizedRequest(
        url: tokenUrl,
        clientId: clientId,
        params: {
          'grant_type': 'https://oauth.reddit.com/grants/installed_client',
          'device_id': deviceId,
        },
        headers: authHeader(clientId));
    return http2TokenResponse(response);
  }

  // MODIFIED
  @override
  Future<AccessTokenResponse> refreshToken(String refreshToken,
      {httpClient, required String clientId, String? clientSecret}) async {
    final Map params = getRefreshUrlParams(refreshToken: refreshToken);

    var response = await _performAuthorizedRequest(
        url: _getRefreshUrl(),
        clientId: clientId,
        clientSecret: clientSecret,
        params: params,
        httpClient: httpClient,
        // MODIFIED
        headers: authHeader(clientId));

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

  Future<String> _getDeviceId() async {
    final token = await storage.storage.read('deviceId');
    if (token != null) {
      return token;
    } else {
      final token = Uuid().v1();
      storage.storage.write('deviceId', token);
      return token;
    }
  }
}
