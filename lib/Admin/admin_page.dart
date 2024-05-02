import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [
    ChatMessage(text: "Hello World!!!", isSentByUser: false),
  ];

  @override
  void initState() {
    _scrollController.addListener(() {
      debugPrint(
          'scrollController: ${_scrollController.position.pixels}, maxScrollExtent: ${_scrollController.position.maxScrollExtent}');
    });
    super.initState();
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        messages.insert(
            0, ChatMessage(text: _textController.text, isSentByUser: true));
        _textController.clear();
      });
    }

    _scrollController.animateTo(
      0.1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageBubble(message: messages[index]);
                },
              ),
            ),
            _ChatEnterBar(
              textController: _textController,
              sendMessage: _sendMessage,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ChatEnterBar extends StatelessWidget {
  const _ChatEnterBar({
    super.key,
    required this.textController,
    required this.sendMessage,
  });

  final TextEditingController textController;
  final void Function() sendMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField.borderless(
              controller: textController,
              placeholder: 'Type your message',
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: sendMessage,
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isSentByUser;

  ChatMessage({required this.text, required this.isSentByUser});
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: message.isSentByUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSentByUser)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
            ),
          Flexible(
            // wrap your Container with Flexible
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: message.isSentByUser
                    ? Colors.yellow[700]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                softWrap: true, // let the text wrap onto the next line
              ),
            ),
          ),
          if (message.isSentByUser)
            CircleAvatar(
              backgroundColor: Colors.yellow[200],
            ),
        ],
      ),
    );
  }
}
