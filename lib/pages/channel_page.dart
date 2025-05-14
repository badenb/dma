import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelPage extends StatelessWidget {
  const ChannelPage({ super.key, required this.channel });

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(
        onBackPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        title: const Text(
            "Chat",
            style: TextStyle(
              color: Colors.white,
            )
        )
      ),
      body: Container (
        color: const Color(0xff121416),
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