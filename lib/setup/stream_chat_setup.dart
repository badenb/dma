import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<StreamChatClient> setupStreamChat() async {
  const streamApiKey = 'uhfx452bn48j';
  const streamApiSecret = '';
  const userId = 'UUID1';
  const username = 'John Doe';
  const userToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiVVVJRDEiLCJleHAiOjE3MTU2OTMwNzB9.mN7dIYlbjnVjZ2szbu4mnAieO-fv-0k6LMQebs4vmbE';
  const theOtherGuy = {
    'id': 'UUID2',
    'name': 'Bobby Tables',
  };

  final client = StreamChatClient(
    streamApiKey,
    logLevel: Level.ALL,
  );

  final currentUser = User(id: userId, extraData: const {
    'name': username,
  });

  await client.connectUser(
    currentUser,
    userToken,
  );

  final channel = client.channel('messaging', id: "private-chat-$userId-${theOtherGuy['id']}", extraData: {
    'name': theOtherGuy['name'],
  });

  await channel.watch();
  await channel.addMembers([userId]);

  return client;
}