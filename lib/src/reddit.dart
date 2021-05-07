import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_reddit/src/auth/authenticator.dart';
import 'package:flutter_reddit/src/auth/authEvent.dart';
import 'package:flutter_reddit/src/const.dart';
import 'package:flutter_reddit/src/auth/oauth_client.dart';
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

  final Dio _dio;

  final _authController = StreamController<AuthEvent>()..add(AuthLoading());

  Reddit({
    required this.clientId,
    required String redirectUri,
    required String customUriScheme,
    required List<String> scopes,
    Dio? dioClient,
    RedditOAuthClient? oAuth2client,
    OAuth2Helper? oAuth2Helper,
    TokenStorage? tokenStorage,
  }) : _dio = dioClient ?? Dio() {
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
          scopes: scopes,
          authCodeParams: {
            'duration': 'permanent',
          },
          tokenStorage: storage,
        );

    // Dio
    _dio.options.contentType = CONTENT_TYPE;

    // Requester
    _requester = Requester(_dio);

    // Authenticator
    _authenticator = Authenticator(_helper, _client, clientId);

    _init();
  }

  void _init() async {
    await _authenticator.getToken();
    if (_authenticator.isAnonymous) {
      _authController.add(AuthAnonymousLogin());
    } else {
      _authController.add(AuthUserLogin());
    }
  }

  Reddit.script({
    required List<String> scopes,
    required String clientSecret,
    required this.clientId,
    Dio? dioClient,
    TokenStorage? tokenStorage,
  }) : _dio = dioClient ?? Dio() {
    final storage = tokenStorage ?? TokenStorage(TOKEN_URL);

    // Client
    _client = RedditOAuthClient(
      redirectUri: '',
      customUriScheme: '',
      storage: storage,
    )..accessTokenRequestHeaders = {
        'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:')),
      };

    // Helper
    _helper = OAuth2Helper(
      _client,
      clientId: clientId,
      grantType: OAuth2Helper.CLIENT_CREDENTIALS,
      clientSecret: clientSecret,
      tokenStorage: storage,
      scopes: scopes,
    );

    // Dio
    _dio.options.contentType = CONTENT_TYPE;

    // Requester
    _requester = Requester(_dio);

    // Authenticator
    _authenticator = Authenticator(_helper, _client, clientId);

    _initScript();
  }

  Future<void> _initScript() async {
    await _helper.getToken();
    _authController.add(AuthScriptLogin());
  }

  Stream<AuthEvent> get authState => _authController.stream;

  Future<void> logIn() async {
    // helper handles everything
    final token = await _helper.fetchToken();
    _requester.setToken(token.accessToken!);
    _authController.add(AuthUserLogin());
  }

  Future<void> logOut() async {
    await _helper.disconnect();
    _requester.setToken(await _authenticator.getToken());
    _authController.add(AuthAnonymousLogin());
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
    //generate url including query parameters (.com?key=value)
    final url = Uri.https(ADDRESS, path, queryParams);
    // callback happens when token is expired and a new one is required
    return _requester.request(type, url, data, () => _authenticator.getToken());
  }

  void dispose() {
    _authController.close();
  }
}
