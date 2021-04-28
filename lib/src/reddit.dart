import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_reddit/src/const.dart';
import 'package:flutter_reddit/src/enum.dart';
import 'package:flutter_reddit/src/oauth_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
// ignore: implementation_imports
import 'package:oauth2_client/src/token_storage.dart';

class Reddit {
  late final RedditOAuthClient oAuthClient;
  late final OAuth2Helper oAuthHelper;

  final String clientId;

  final Dio dio;

  String? _anonymousToken;

  Reddit({
    required this.clientId,
    required String redirectUri,
    required String customUriScheme,
    Dio? dioClient,
  }) : dio = dioClient ?? Dio() {
    final storage = TokenStorage(TOKEN_URL);

    // OAuthClient
    oAuthClient = RedditOAuthClient(
      redirectUri: redirectUri,
      customUriScheme: customUriScheme,
      storage: storage,
    )..accessTokenRequestHeaders = {
        'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:')),
      };

    // OAuthHelper
    oAuthHelper = OAuth2Helper(
      oAuthClient,
      clientId: clientId,
      scopes: ['identity', 'read', 'vote'],
      authCodeParams: {
        'duration': 'permanent',
      },
      tokenStorage: storage,
    );

    // DIO
    dio.options.contentType = 'application/x-www-form-urlencoded';
  }

  Future<String> _getToken() async {
    late final String token;

    // use anonymous token first
    if (_anonymousToken != null) {
      token = _anonymousToken!;
    } else {
      // if it doesnt exist, then check if token not in storage
      final _token = await oAuthHelper.getTokenFromStorage();
      if (_token == null || !_token.hasRefreshToken()) {
        // should get token from appOnly auth
        final res = await oAuthClient.getTokenWithAppOnlyFlow(
          clientId: clientId,
        );
        // set anonymous token for "caching"
        _anonymousToken = res.accessToken!;
        token = res.accessToken!;
      } else {
        // token is in storage and used
        final res = await oAuthHelper.getToken();

        token = res!.accessToken!;
        // set anonymous token to null just in case it wasn't before
        _anonymousToken = null;
      }
    }

    return token;
  }

  Future<void> login() async {
    await oAuthHelper.fetchToken();
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? queryParams, dynamic data}) async {
    final url = Uri.https(ADDRESS, path, queryParams);
    return _request(RequestType.POST, url, data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    // wait until token is present

    final url = Uri.https(ADDRESS, path, queryParams);
    return dio.getUri(url);
  }

  Future<Response> _request(RequestType type, Uri url, dynamic body) async {
    Future<Response> send(String token) async {
      dio.options.headers = {'Authorization': 'bearer $token'};
      switch (type) {
        case RequestType.GET:
          return dio.getUri(url);
        case RequestType.POST:
          return dio.postUri(url, data: body);
        default:
          throw '';
      }
    }

    final token = await _getToken();

    late Response res;

    try {
      res = await send(token);
    } catch (e) {
      if (e is DioError) {
        if (e.response!.statusCode == 401) {
          //try getting the token again
          res = await send(await _getToken());
        }
      }
    }
    return res;
  }
}
