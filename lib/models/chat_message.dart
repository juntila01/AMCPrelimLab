import 'package:hive/hive.dart';
part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  String role;

  @HiveField(2)
  DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });

  bool get isUserMessage => role == "user";
}
