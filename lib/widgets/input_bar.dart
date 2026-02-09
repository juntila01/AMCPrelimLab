import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class InputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final String? hintText; // 🔹 Add optional hintText parameter

  const InputBar({
    Key? key,
    required this.onSendMessage,
    this.hintText, // 🔹 optional
  }) : super(key: key);

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _textController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
    }
  }

  void _toggleListening() async {
    if (!_isListening) {
      // 🔹 Clear previous text BEFORE starting a new mic session
      _textController.clear();

      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
              _textController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textController.text.length),
              );
            });
          },
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        );
      }
    } else {
      // 🔹 Stop & fully reset speech engine
      setState(() => _isListening = false);
      await _speech.stop();
      await _speech.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Mic button
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            color: _isListening ? Colors.red : Colors.blue,
            onPressed: _toggleListening,
          ),

          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Type your message...', // 🔹 Use hintText
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),

          // Send button
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
