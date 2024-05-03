import 'package:flutter/material.dart';
import 'package:login_flutter/model/chat_message.dart';
import 'package:login_flutter/util/local_data_storage.dart';

class ChatsManager with ChangeNotifier {
  ChatsManager() {
    loadChatMessages();
  }
  final List<ChatMessage> _chats = [];

  List<ChatMessage> get chats => _chats;

  Future<void> loadChatMessages() async {
    // TODO: load chat messages from server
    final chatMessages = await LocalDataBase.getAllChatMessages();
    _chats.addAll(chatMessages);
    notifyListeners();
  }

  Future<ChatMessage?> sendChatMessage(
      {required String chatMessage, required int senderId}) async {
    final messageCreated =
        await LocalDataBase.saveChatMessage(chatMessage, senderId);

    if (messageCreated != null) {
      _chats.insert(0, messageCreated);
    }
    notifyListeners();

    return messageCreated;
  }
}
