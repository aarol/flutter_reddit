import 'package:flutter_reddit/env/env.dart';
import 'package:flutter_reddit/src/auth/authenticator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../generated.mocks.dart';

void main() {
  late Authenticator authenticator;
  late MockOAuth2Helper helper;
  late MockRedditOAuthClient client;

  late MockAccessTokenResponse mockToken;

  setUp(() {
    helper = MockOAuth2Helper();
    client = MockRedditOAuthClient();
    authenticator = Authenticator(helper, client, Env.client_id);
    mockToken = MockAccessTokenResponse();
  });
  group('getToken', () {
    final tToken = 'tToken';
    test('should use anonymous token when possible', () async {
      // arrange
      authenticator.anonymousToken = tToken;
      // act
      final token = await authenticator.getToken();
      //assert
      expect(token, tToken);
    });

    test(
      'should use refresh token when anonymous not available',
      () async {
        // arrange
        when(helper.getTokenFromStorage()).thenAnswer((_) async => mockToken);
        when(helper.getToken())..thenAnswer((_) async => mockToken);
        when(mockToken.hasRefreshToken()).thenReturn(true);
        when(mockToken.accessToken).thenReturn(tToken);
        // act
        final token = await authenticator.getToken();
        // assert
        expect(token, tToken);
        verify(helper.getTokenFromStorage());
        verify(helper.getToken());
      },
    );

    test(
      'if neither are available then use app only',
      () async {
        // arrange
        when(helper.getTokenFromStorage()).thenAnswer((_) async => null);
        when(client.getTokenWithAppOnlyFlow(clientId: anyNamed('clientId')))
            .thenAnswer((_) async => mockToken);
        when(mockToken.accessToken).thenReturn(tToken);
        // act
        final token = await authenticator.getToken();
        // assert
        expect(token, tToken);
        verify(client.getTokenWithAppOnlyFlow(clientId: Env.client_id));
      },
    );
  });
}
