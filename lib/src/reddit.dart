import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_reddit/src/authEvent.dart';
import 'package:flutter_reddit/src/const.dart';
import 'package:flutter_reddit/src/enum.dart';
import 'package:flutter_reddit/src/oauth_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
// ignore: implementation_imports
import 'package:oauth2_client/src/token_storage.dart';

class Reddit {
  late final RedditOAuthClient _client;
  late final OAuth2Helper _helper;

  final String clientId;

  final Dio dio;

  final _authController = StreamController<AuthEvent>()..add(AuthLoading());

  String? _anonymousToken;

  Reddit({
    required this.clientId,
    required String redirectUri,
    required String customUriScheme,
    Dio? dioClient,
    RedditOAuthClient? oAuth2client,
    OAuth2Helper? oAuth2Helper,
    TokenStorage? tokenStorage,
  }) : dio = dioClient ?? Dio() {
    final storage = tokenStorage ?? TokenStorage(TOKEN_URL);

    // OAuthClient
    _client = oAuth2client ??
        RedditOAuthClient(
          redirectUri: redirectUri,
          customUriScheme: customUriScheme,
          storage: storage,
        )
      ..accessTokenRequestHeaders = {
        'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:')),
      };

    // OAuthHelper
    _helper = oAuth2Helper ??
        OAuth2Helper(
          _client,
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
      final _token = await _helper.getTokenFromStorage();
      if (_token == null || !_token.hasRefreshToken()) {
        // should get token from appOnly auth
        final res = await _client.getTokenWithAppOnlyFlow(
          clientId: clientId,
        );
        // set anonymous token for "caching"
        _anonymousToken = res.accessToken!;
        token = res.accessToken!;
      } else {
        // token is in storage and used
        final res = await _helper.getToken();

        token = res!.accessToken!;
        // set anonymous token to null just in case it wasn't before
        _anonymousToken = null;
      }
    }

    return token;
  }

  Future<void> login() async {
    await _helper.fetchToken();
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? queryParams, dynamic data}) async {
    final url = Uri.https(ADDRESS, path, queryParams);
    return _request(RequestType.POST, url, body: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    // wait until token is present

    final url = Uri.https(ADDRESS, path, queryParams);
    return _request(RequestType.GET, url);
  }

  Future<Response> _request(RequestType type, Uri url, {dynamic body}) async {
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

  void dispose() {
    _authController.close();
  }
}
