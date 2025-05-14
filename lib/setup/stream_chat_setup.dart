import 'package:flutter/foundation.dart';
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

  final userId = creds.user.sub.replaceAll('|', '_');
  final username = creds.user.name;

  debugPrint('==========> User: ${creds.user.toMap()}');

  final client = StreamChatClient(streamApiKey, logLevel: Level.ALL);
  final userToken = client.devToken(userId).rawValue;

  final currentUser = User(id: userId, extraData: {
    'name': username,
  });

  client.updateUser(currentUser);
  
  await client.connectUser(currentUser, userToken);

  return client;
}


  // final channel = client.channel('messaging', id: "private-chat-$userId-${theOtherGuy['id']}", extraData: {
  //   'name': theOtherGuy['name'],
  //   'members': [userId, theOtherGuy['id']],
  // });
  // await channel.watch();