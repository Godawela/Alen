import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  final ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gemini ChatBot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    String question = chatMessage.text ?? "";

    try {
      gemini.streamGenerateContent(question).listen((event) {
        String response = event.content?.parts?.fold(
              "",
              (previous, current) => "$previous ${current.text}",
            ) ??
            "";

        ChatMessage botMessage;

        // Check if the last message was from the bot
        if (messages.isNotEmpty && messages.first.user == geminiUser) {
          // Update the existing bot message
          botMessage = messages.first;
          botMessage.text = response;
        } else {
          // Create a new bot message
          botMessage = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          messages.insert(0, botMessage);
        }

        setState(() {
          messages = [...messages];
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
