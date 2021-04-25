import 'dart:convert';

import 'package:flutter_reddit/oauth_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class Reddit {
  late final RedditOAuthClient oAuthClient;
  late final OAuth2Helper oAuthHelper;

  final String clientId;

  Reddit({
    required this.clientId,
    required String redirectUri,
    required String customUriScheme,
  }) {
    oAuthClient = RedditOAuthClient(
      redirectUri: redirectUri,
      customUriScheme: customUriScheme,
    );
    oAuthHelper = OAuth2Helper(oAuthClient, clientId: clientId, scopes: [
      'identity',
      'read',
      'vote'
    ], authCodeParams: {
      'duration': 'permanent',
    });
    _init();
  }

  void _init() {
    print('hi');
    oAuthClient.accessTokenRequestHeaders = {
      'authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:')),
    };
  }

  void login() async {
    final token = await oAuthHelper.fetchToken();
    print(token.refreshToken);
  }

  void request() async {
    final response =
        await oAuthHelper.get('https://oauth.reddit.com/api/v1/me');
    print(response.body);
  }
}
