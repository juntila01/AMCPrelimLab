import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/chat_screen.dart';
import '../models/chat_session.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ChatSession>('sessions');

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Text(
              'Conversation History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // ✅ NEW CHAT BUTTON (ADDED)
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          ),

          const Divider(),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<ChatSession> sessionsBox, _) {
                final sessions = sessionsBox.values.toList().reversed.toList();

                if (sessions.isEmpty) {
                  return const Center(
                    child: Text('No past conversations yet.'),
                  );
                }

                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ListTile(
                      title: Text(session.title),
                      subtitle: Text('${session.messages.length} messages'),
                      leading: const Icon(Icons.chat_bubble_outline),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              pastMessages: session.messages,
                              sessionTitle: session.title,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
