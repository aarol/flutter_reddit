import 'package:dio/dio.dart';
import 'package:flutter_reddit/src/oauth_client.dart';
import 'package:mockito/annotations.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/src/token_storage.dart';
import 'package:oauth2_client/src/storage.dart';

@GenerateMocks([
  TokenStorage,
  Storage,
  OAuth2Helper,
  RedditOAuthClient,
  AccessTokenResponse,
])
void main() {}
