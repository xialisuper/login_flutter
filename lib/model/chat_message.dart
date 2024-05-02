class ChatMessage {
  final String content;
  final bool isSentByUser;

  ChatMessage({required this.content, required this.isSentByUser});

  // to map
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'isSentByUser': isSentByUser? 1 : 0,
    };
  }




  // to string
  @override
  String toString() {
    return 'ChatMessage(content: $content, isSentByUser: $isSentByUser)';
  }
}
