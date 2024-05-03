class ChatMessage {
  final String messageContent;
  final int senderId;
  final int receiverId;
  final String timestamp;

  ChatMessage({
    required this.messageContent,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'message_content': messageContent,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'timestamp': timestamp
    };
  }

  // from map
  ChatMessage.fromMap(Map<String, dynamic> map)
      : messageContent = map['message_content'],
        senderId = map['sender_id'],
        receiverId = map['receiver_id'],
        timestamp = map['timestamp'];

  // to string
  @override
  String toString() {
    return 'ChatMessage{messageContent: $messageContent, , senderId: $senderId, receiverId: $receiverId, timestamp: $timestamp}';
  }
}
