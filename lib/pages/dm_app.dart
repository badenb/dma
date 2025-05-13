import 'package:dma/pages/channel_list_page.dart';
import 'package:dma/setup/stream_chat_setup.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

const backgroundColor = Color(0xff121416);
const messagePrimaryColor = Colors.blueAccent;

class DmApp extends StatefulWidget {
  const DmApp({ super.key });

  @override
  _DmAppState createState() => _DmAppState();
}

class _DmAppState extends State<DmApp> with WidgetsBindingObserver {
  late Future<StreamChatClient> _clientFuture;

  late Auth0 auth0;
  late Credentials credentials;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    auth0 = Auth0("dev-gmtdctal4lxr7i3j.us.auth0.com", "L5aPLJRptTzTQplbka3zJsjijPEZO9QT");
    print(auth0);
    _clientFuture = _initializeStreamChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<StreamChatClient> _initializeStreamChat() async {
    return await setupStreamChat(auth0);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      setState(() {
        _clientFuture = _initializeStreamChat();
      });
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      (await _clientFuture).disconnectUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StreamChatClient>(
      future: _clientFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(messagePrimaryColor),
          ));
        } else {
          
          if (snapshot.hasError) {
            return MaterialApp(
              color: Colors.black,
              home: Scaffold(
                backgroundColor: backgroundColor,
                body: Center(
                  child: Text(
                    'Error connecting to chat:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(messagePrimaryColor),
            ));
          }

          final client = snapshot.data!;

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
      },
    );
  }
}


