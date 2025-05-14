import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:dma/pages/channel_page.dart';

const backgroundColor = Color(0xff121416);

class UserListPage extends StatefulWidget {
  const UserListPage({super.key, required this.client});

  final StreamChatClient client;

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> _users = [];
  final Set<String> _selected = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final currentUserId = widget.client.state.currentUser!.id;
      final response = await widget.client.queryUsers(
        filter: Filter.notEqual('id', currentUserId),
      );
      setState(() {
        _users = response.users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _startChat() async {
    final currentUserId = widget.client.state.currentUser!.id;
    final memberIds = <String>[currentUserId, ..._selected];

    final channel = widget.client.channel(
      'messaging',
      extraData: { 'members': memberIds },
    );

    await channel.watch();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StreamChannel(
          channel: channel,
          child: ChannelPage(channel: channel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Error loading users:\n$_error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Select Users'),
        backgroundColor: backgroundColor,
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final name = user.extraData['name'] as String? ?? user.id;
          final selected = _selected.contains(user.id);
          return CheckboxListTile(
            title: Text(name, style: const TextStyle(color: Colors.white)),
            value: selected,
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selected.add(user.id);
                } else {
                  _selected.remove(user.id);
                }
              });
            },
            tileColor: backgroundColor,
            checkColor: Colors.black,
            activeColor: Colors.greenAccent,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selected.isEmpty ? null : _startChat,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.chat),
      ),
    );
  }
}
