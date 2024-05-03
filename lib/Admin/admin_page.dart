import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/model/chat_message.dart';
import 'package:login_flutter/util/local_data_storage.dart';
import 'package:login_flutter/util/toast.dart';
import 'package:login_flutter/util/user_info.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  void _loadChatMessages() async {
    final List<ChatMessage> chatMessages =
        await LocalDataBase.getAllChatMessages();
    setState(() {
      messages.addAll(chatMessages);
    });
  }

  Future<void> _sendMessage(BuildContext context) async {
    if (_textController.text.isEmpty) {
      MyToast.showToast(msg: '请输入内容', type: ToastType.error);
      return;
    }

    // save message to local database before update ui, otherwise _textController.clear() will clean the message inputField and insert a empty message into database

    final useInfo = Provider.of<UserModel>(context, listen: false).userInfo;

    if (useInfo == null) {
      MyToast.showToast(msg: '请先登录', type: ToastType.error);
      return;
    }

    final messageCreated = await LocalDataBase.saveChatMessage(
      _textController.text,
      useInfo.userId,
    );

    if (messageCreated == null) {
      MyToast.showToast(msg: '消息保存失败', type: ToastType.error);
      return;
    }

    setState(() {
      messages.insert(0, messageCreated);

      // clear message inputField
      _textController.clear();
    });

    _scrollController.animateTo(
      0.1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleAdminLogOut(BuildContext context) async {
    await LocalDataBase.onAdminLogOut();

    if (!context.mounted) return;
    Provider.of<UserModel>(context, listen: false).logOut();
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage()),
      ModalRoute.withName('/login'),
    );
  }

  // This shows a CupertinoModalPopup which hosts a CupertinoActionSheet.
  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// default behavior, turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Default Action'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Action'),
          ),
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              _handleAdminLogOut(context);
              Navigator.pop(context);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showActionSheet(context)),
        ],
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
              sendMessage: () => _sendMessage(context),
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

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserModel>(context, listen: false).userInfo;
    final isMessageSendByCurrentUser = message.senderId == userInfo?.userId;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // avatars are aligned to the left for the current user, and to the right for the other user
        mainAxisAlignment: isMessageSendByCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMessageSendByCurrentUser)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isMessageSendByCurrentUser
                    ? Colors.yellow[700]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.messageContent,
                softWrap: true, // let the text wrap onto the next line
              ),
            ),
          ),
          if (isMessageSendByCurrentUser)
            CircleAvatar(
              backgroundColor: Colors.yellow[200],
            ),
        ],
      ),
    );
  }
}
