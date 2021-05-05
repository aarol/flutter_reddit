import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_reddit/src/auth/authenticator.dart';
import 'package:flutter_reddit/src/authEvent.dart';
import 'package:flutter_reddit/src/const.dart';
import 'package:flutter_reddit/src/oauth_client.dart';
import 'package:flutter_reddit/src/request/requester.dart';
import 'package:oauth2_client/oauth2_helper.dart';
// ignore: implementation_imports
import 'package:oauth2_client/src/token_storage.dart';

class Reddit {
  late final RedditOAuthClient _client;
  late final OAuth2Helper _helper;
  late final Requester _requester;
  late final Authenticator _authenticator;

  final String clientId;

  final Dio dio;

  final _authController = StreamController<AuthEvent>()..add(AuthLoading());

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

    // Dio
    dio.options.contentType = 'application/x-www-form-urlencoded';

    // Requester
    _requester = Requester(dio);

    // Authenticator
    _authenticator = Authenticator(_helper, _client, clientId);

    _init();
  }

  void _init() async {
    await _authenticator.getToken();
    if (_authenticator.isAnonymous) {
      _authController.add(AuthLoggedOut());
    } else {
      _authController.add(AuthLoggedIn());
    }
  }

  Stream<AuthEvent> get authState => _authController.stream;

  Future<void> login() async {
    await _helper.fetchToken();
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? queryParams, dynamic data}) async {
    return _request(RequestType.POST, path, queryParams, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return _request(RequestType.GET, path, queryParams);
  }

  Future<Response> _request(
      RequestType type, String path, Map<String, dynamic>? queryParams,
      {dynamic data}) async {
    final url = Uri.https(ADDRESS, path, queryParams);

    return _requester.request(type, url, data, () => _authenticator.getToken());
  }

  void dispose() {
    _authController.close();
  }
}
