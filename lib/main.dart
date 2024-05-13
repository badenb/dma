import 'package:dma/pages/ChannelListPage.dart';
import 'package:dma/setup/firebase_setup.dart';
import 'package:dma/setup/stream_chat_setup.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

const backgroundColor = Color(0xff121416);
const messagePrimaryColor = Colors.blueAccent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFirebase();

  final client = await setupStreamChat();

  runApp(DmApp(client: client));
}

class DmApp extends StatefulWidget {
  const DmApp({
    super.key,
    required this.client,
  });

  final StreamChatClient client;

  @override
  _DmAppState createState() => _DmAppState();
}

class _DmAppState extends State<DmApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      widget.client.disconnectUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

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


