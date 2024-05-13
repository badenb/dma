import 'package:dma/pages/ChannelListPage.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

const backgroundColor = Color(0xff121416);
const messagePrimaryColor = Colors.blueAccent;

void main() async {
  const streamApiKey = 'uhfx452bn48j';
  const streamApiSecret = '';
  const userId = 'UUID1';
  const username = 'John Doe';
  const userToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiVVVJRDEiLCJleHAiOjE3MTU2MzUzODZ9.oEpFxPYMp7QW9g4OufFKqBjCc9BB4NKK21lY6BJLPQA';
  const theOtherGuy = {
    'id': 'UUID2',
    'name': 'Bobby Tables',
  };

  final client = StreamChatClient(
    streamApiKey,
    logLevel: Level.INFO,
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

  runApp(
    DmApp(client: client),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth.FirebaseAuth.instance
      .authStateChanges()
      .listen((auth.User? user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          print('User is signed in!');
        }
      });

  auth.FirebaseAuth.instance
      .idTokenChanges()
      .listen((auth.User? user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          print('User is signed in!');
        }
      });

  auth.FirebaseAuth.instance
    .userChanges()
    .listen((auth.User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
}

class DmApp extends StatelessWidget {
  const DmApp({
    super.key,
    required this.client,
  });

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: messagePrimaryColor,
          selectionColor: messagePrimaryColor.withOpacity(0.5),
          selectionHandleColor: messagePrimaryColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
      ),
      builder: (context, widget) {
        return StreamChat(
          client: client,
          streamChatThemeData: StreamChatThemeData(
            colorTheme: StreamColorTheme.dark(),
            textTheme: StreamTextTheme.dark(),
            channelHeaderTheme: const StreamChannelHeaderThemeData(
              titleStyle: TextStyle(
                color: Colors.white,
              ),
              subtitleStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            ownMessageTheme: const StreamMessageThemeData(
              messageBackgroundColor: messagePrimaryColor,
              messageTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            messageInputTheme: const StreamMessageInputThemeData(
              sendButtonColor: messagePrimaryColor,
              expandButtonColor: messagePrimaryColor,
              actionButtonColor: messagePrimaryColor,
              inputDecoration: InputDecoration(
                hintText: 'Type a message',
              )
            ),
          ),
          child: widget,
        );
      },
      home: ChannelListPage(client: client),
    );
  }
}


