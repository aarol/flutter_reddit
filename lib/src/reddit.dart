import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_reddit/src/const.dart';
import 'package:flutter_reddit/src/oauth_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

import 'package:http/http.dart' as http;

class Reddit {
  late final RedditOAuthClient oAuthClient;
  late final OAuth2Helper oAuthHelper;

  final String clientId;

  final Dio dio;

  Reddit({
    required this.clientId,
    required String redirectUri,
    required String customUriScheme,
    Dio? dioClient,
  }) : dio = dioClient ?? Dio() {
    // OAuthClient
    oAuthClient = RedditOAuthClient(
      redirectUri: redirectUri,
      customUriScheme: customUriScheme,
    )..accessTokenRequestHeaders = {
        'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:')),
      };

    // OAuthHelper
    oAuthHelper = OAuth2Helper(oAuthClient, clientId: clientId, scopes: [
      'identity',
      'read',
      'vote'
    ], authCodeParams: {
      'duration': 'permanent',
    });

    // DIO
    dio.options.contentType = 'application/x-www-form-urlencoded';
  }

  Future<void> _prepareForRequest() async {
    final token = await oAuthHelper.getToken();
    dio.options.headers = {'Authorization': 'bearer $token'};
  }

  void login() async {
    final token = await oAuthHelper.fetchToken();
    print(token.refreshToken);
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? queryParams, dynamic data}) async {
    // wait until token is present
    await _prepareForRequest();
    final url = Uri.https(ADDRESS, path, queryParams);
    return dio.postUri(url, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    // wait until token is present
    await _prepareForRequest();
    final url = Uri.https(ADDRESS, path, queryParams);
    return dio.getUri(url);
  }
}
