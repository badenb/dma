import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:dma/pages/ChannelPage.dart';

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({ super.key, required this.client });

  final StreamChatClient client;

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late final StreamChannelListController _listController;

  @override
  void initState() {
    super.initState();
    final currentUser = StreamChat.of(context).currentUser;

    if (currentUser != null) {
      _listController = StreamChannelListController(
        client: widget.client,
        filter: Filter.in_('members', [currentUser.id]),
        channelStateSort: const [SortOption('last_message_at')],
      );
    } else {
      throw Exception('Current user is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      backgroundColor: Colors.black26,
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

}