import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

Future<StreamChatClient> setupStreamChat(Auth0 auth0) async {
  const streamApiKey = 'uhfx452bn48j';

  late Credentials creds;

  try {
    creds = await auth0.credentialsManager.credentials();
  } catch (_) {
    creds = await auth0.webAuthentication().login();
    await auth0.credentialsManager.storeCredentials(creds);
  }

  final userId = creds.user.sub;
  final username = creds.user.name;

  final client = StreamChatClient(streamApiKey, logLevel: Level.ALL);

  final currentUser = User(id: userId, extraData: {
    'name': username,
  });

  final userToken = client.devToken(userId).rawValue;

  await client.connectUser(currentUser, userToken);

  const theOtherGuy = {
    'id': 'UUID2',
    'name': 'Pesto Besto',
  };

  final channel = client.channel('messaging', id: "private-chat-$userId-${theOtherGuy['id']}", extraData: {
    'name': theOtherGuy['name'],
    'members': [userId, theOtherGuy['id']],
  });

  await channel.watch();
  return client;
}