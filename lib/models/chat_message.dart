class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isOfflineFallback;
  final List<String>? suggestedFollowUps;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isOfflineFallback = false,
    this.suggestedFollowUps,
  });
}
