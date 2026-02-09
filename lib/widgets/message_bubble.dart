import 'package:flutter/material.dart';
import '/models/chat_message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String selectedPersonality;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.selectedPersonality,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔹 Personality colors for AI messages
    final Map<String, Color> personalityColors = {
      'fitness': Colors.green.shade700,
      'makeup': Colors.pink.shade700,
      'fashion': Colors.purple.shade700,
      'gamer': Colors.orange.shade700,
      'relationship': Colors.red.shade700,
    };

    // 🔹 Personality shapes for AI messages (BorderRadius)
    final Map<String, BorderRadius> personalityShapes = {
      'fitness': BorderRadius.circular(24),
      'makeup': BorderRadius.circular(30),
      'fashion': BorderRadius.circular(12),
      'gamer': const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(24),
      ),
      'relationship': BorderRadius.circular(20),
    };

    final isUser = message.isUserMessage;

    final bubbleColor = isUser
        ? Colors.blue[300]
        : personalityColors[selectedPersonality] ?? Colors.green[700];

    final bubbleRadius = isUser
        ? BorderRadius.circular(18)
        : personalityShapes[selectedPersonality] ?? BorderRadius.circular(18);

    // 🕒 Time & date formatting
    final time = DateFormat('hh:mm a').format(message.timestamp);
    final date = DateFormat('MMM d, yyyy').format(message.timestamp);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: bubbleRadius,
        ),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '$time • $date',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
