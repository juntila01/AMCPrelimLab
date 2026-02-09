import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/sidebar.dart';
import '../services/gemini_service.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final List<ChatMessage>? pastMessages;
  final String? sessionTitle;

  const ChatScreen({super.key, this.pastMessages, this.sessionTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

  late Box<ChatSession> sessionBox;
  late ChatSession currentSession;

  // 🔹 Personality selection
  String selectedPersonality = 'default'; // default AI
  final Map<String, String> personalityNames = {
    'default': 'AI Assistant',
    'fitness': 'Fitness Coach',
    'makeup': 'Make-up Artist',
    'fashion': 'Fashion Specialist',
    'gamer': 'Professional Gamer',
    'relationship': 'Relationship Consultant',
  };

  final Map<String, Map<String, dynamic>> personalityStyles = {
    'default': {
      'color': Colors.blue,
      'icon': Icons.smart_toy,
      'inputHint': 'Ask me anything...',
    },
    'fitness': {
      'color': Colors.green,
      'icon': Icons.fitness_center,
      'inputHint': 'Ask your fitness coach...',
    },
    'makeup': {
      'color': Colors.pink,
      'icon': Icons.brush,
      'inputHint': 'Ask your make-up artist...',
    },
    'fashion': {
      'color': Colors.purple,
      'icon': Icons.checkroom,
      'inputHint': 'Ask your fashion specialist...',
    },
    'gamer': {
      'color': Colors.orange,
      'icon': Icons.videogame_asset,
      'inputHint': 'Ask your gamer...',
    },
    'relationship': {
      'color': Colors.red,
      'icon': Icons.favorite,
      'inputHint': 'Ask your relationship consultant...',
    },
  };

  @override
  void initState() {
    super.initState();
    sessionBox = Hive.box<ChatSession>('sessions');

    // 🔹 Create default session
    currentSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.sessionTitle ?? personalityNames[selectedPersonality]!,
      messages: widget.pastMessages != null
          ? List.from(widget.pastMessages!)
          : [],
    );

    messages.addAll(currentSession.messages);
  }

  void addMessage(String text, String role) {
    final msg = ChatMessage(
      text: text,
      role: role,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(msg);
      currentSession.messages.add(msg);
    });

    scrollToBottom();

    // Save session immediately
    sessionBox.put(currentSession.id, currentSession);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> handleSend(String text) async {
    addMessage(text, "user");

    setState(() => _isLoading = true);

    try {
      final aiResponse = await GeminiService.sendMultiTurnMessage(
        messages,
        selectedPersonality,
      );
      addMessage(aiResponse, "model");
    } catch (e) {
      addMessage('❌ Error: $e', "model");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void switchPersona(String newPersona) {
    if (newPersona != selectedPersonality) {
      setState(() {
        selectedPersonality = newPersona;

        // 🔹 Start a new session for the new persona
        currentSession = ChatSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: personalityNames[newPersona]!,
          messages: [],
        );

        messages.clear();

        // Save the empty session in Hive
        sessionBox.put(currentSession.id, currentSession);

        // Optional: send a welcome message for the new persona
        addMessage(
          "Hello! I am your ${personalityNames[newPersona]}. Ask me anything in my field!",
          "model",
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionTitle ?? personalityNames[selectedPersonality]!),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            tooltip: 'Dark and Light Mode',
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          // 🔹 Personality dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: selectedPersonality,
              dropdownColor: personalityStyles[selectedPersonality]!['color'],
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: personalityNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) switchPersona(value);
              },
            ),
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Start chatting!'),
                  Text(
                    '',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return MessageBubble(
                  message: msg,
                  selectedPersonality: selectedPersonality,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 12),
                  Text('Generating Response...'),
                ],
              ),
            ),
          // 🔹 Dynamic InputBar hint based on persona
          InputBar(
            onSendMessage: handleSend,
            hintText: personalityStyles[selectedPersonality]!['inputHint'],
          ),
        ],
      ),
    );
  }
}
