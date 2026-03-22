import 'package:get/get.dart';
import 'dart:math';
import '../../data/models/chat_message.dart';
import 'data/qa_data.dart';

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<String> suggestedQuestions = <String>[].obs;

  // API key for external chatbot service (if used)
  final String apiKey = 'YOUR_API_KEY_HERE';

  // Initial suggestions shown when the chat first opens
  final List<String> initialSuggestions = [
    'What should I eat before a workout?',
    'How can I lose weight effectively?',
    'How much water should I drink daily?',
    'What are good exercises for beginners?',
    'How can I improve my sleep quality?',
    'Tell me about intermittent fasting',
  ];

  // Random generator for picking follow-up suggestions
  final Random _random = Random();

  // Send a message (either from predefined questions or custom user input)
  void sendMessage(String text) {
    // Add user message
    messages.add(
      ChatMessage(
        text: text,
        timestamp: DateTime.now(),
        type: MessageType.user,
      ),
    );

    // Get bot response
    _respondToMessage(text);
  }

  // Use local QA data or API to generate response
  void _respondToMessage(String userMessage) {
    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // First try to find exact match in our predefined QA data
      final String response = QAData.getResponse(userMessage);

      // Add bot response
      messages.add(
        ChatMessage(
          text: response,
          timestamp: DateTime.now(),
          type: MessageType.bot,
        ),
      );

      // Generate related suggestions
      _generateSuggestions(userMessage);
    });
  }

  // Generate follow-up suggestions based on the current conversation
  void _generateSuggestions(String lastUserMessage) {
    // Get related questions from QA data
    final relatedQuestions = QAData.getRelatedQuestions(lastUserMessage);

    // If we have related questions, use them
    if (relatedQuestions.isNotEmpty) {
      // Shuffle and take up to 3 questions
      suggestedQuestions.value =
          relatedQuestions.toList()
            ..shuffle(_random)
            ..take(3).toList();
    } else {
      // Otherwise use some default follow-up questions
      suggestedQuestions.value = _getRandomDefaultSuggestions(3);
    }
  }

  // Get random default suggestions
  List<String> _getRandomDefaultSuggestions(int count) {
    final defaultSuggestions = [
      'What`s a good protein intake for muscle gain?',
      'How can I stay motivated to exercise?',
      'Tell me about HIIT workouts',
      'What should I eat after a workout?',
      'How many days a week should I work out?',
      'Are supplements necessary?',
      'What`s the best time to work out?',
      'How can I track my fitness progress?',
    ];

    // Shuffle and take requested number of suggestions
    defaultSuggestions.shuffle(_random);
    return defaultSuggestions.take(count).toList();
  }

  // Reset the chat
  void resetChat() {
    messages.clear();
    suggestedQuestions.clear();
  }
}
