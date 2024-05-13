import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const backgroundColor = Color(0xff121416);
const messagePrimaryColor = Colors.blueAccent;

void main() async {
  const streamApiKey = '';
  const streamApiSecret = '';
  const userId = '';
  const username = '';
  const userToken = '';
  const theOtherGuy = {};

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

  final channel = client.channel('messaging', id: 'private-chat-$userId-$theOtherGuy', extraData: {
    'name': 'Private Chat',
    'members': [userId],
  });

  await channel.watch();
  await channel.addMembers([userId]);

  runApp(
    DmApp(client: client),
  );
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

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({ super.key, required this.client });

  final StreamChatClient client;

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late final _listController = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_('members', [StreamChat.of(context).currentUser!.id]),
    channelStateSort: const [SortOption('last_message_at')],
  );

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: StreamChannelListHeader(
        titleBuilder: (context, status, client) => const Text(
          'Stream Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    body: SlidableAutoCloseBehavior(
      child: RefreshIndicator(
        onRefresh: _listController.refresh,
        child: StreamChannelListView(
          controller: _listController,
          itemBuilder: (context, channels, index, tile) {
            final channel = channels[index];
            final chatTheme = StreamChatTheme.of(context);
            final canDeleteChannel = channel.ownCapabilities.contains(PermissionType.deleteChannel);

            return Slidable(
              groupTag: 'channels-actions',
              endActionPane: ActionPane(
                extentRatio: canDeleteChannel ? 0.40 : 0.20,
                motion: const BehindMotion(),
                children: [
                  CustomSlidableAction(
                    backgroundColor: backgroundColor,
                    child: StreamSvgIcon.delete(
                      color: chatTheme.colorTheme.accentError,
                    ),
                    onPressed: (_) async {
                      final res = await showConfirmationBottomSheet(
                        context,
                        title: 'Delete Conversation',
                        question: 'Are you sure you want to delete this conversation?',
                        okText: 'Delete',
                        cancelText: 'Cancel',
                        icon: StreamSvgIcon.delete(
                          color: chatTheme.colorTheme.accentError,
                        ),
                      );
                      if (res == true) {
                        await _listController.deleteChannel(channel);
                      }
                    },
                  ),
                ],
              ),
              child: tile,
            );
          },
          onChannelTap: (channel) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StreamChannel(
                channel: channel,
                child: ChannelPage(channel: channel),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({ super.key, required this.channel });

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(
        title: Text(
          channel.id.toString(),
          style: const TextStyle(
            color: Colors.white,
          )
        ),
      ),
      body: Container (
        color: backgroundColor,
        child: const Column(
          children: <Widget>[
            Expanded(
              child: StreamMessageListView(
                showFloatingDateDivider: false,
              )
            ),
            StreamMessageInput()
          ],
        ),
      ),
    );
  }
}
