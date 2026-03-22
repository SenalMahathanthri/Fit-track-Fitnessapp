import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/chat_message.dart';
import 'chatbot_controller.dart';
import 'widgets/message_bubble.dart';
import 'widgets/suggestion_chip.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotController _controller = Get.put(ChatbotController());
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    _controller.sendMessage(text);
    _scrollToBottom();
  }

  void _handleSuggestionTap(String suggestion) {
    _controller.sendMessage(suggestion);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitBot Assistant',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () => _controller.resetChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() {
              if (_controller.messages.isEmpty) {
                return _buildWelcomeScreen();
              }

              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  final message = _controller.messages[index];
                  return MessageBubble(
                    message: message,
                    isLastMessage: index == _controller.messages.length - 1,
                  );
                },
              );
            }),
          ),

          // Suggested questions chips
          Obx(() {
            if (_controller.messages.isNotEmpty &&
                _controller.messages.last.type == MessageType.bot) {
              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerLeft,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      _controller.suggestedQuestions
                          .map(
                            (question) => SuggestionChip(
                              question: question,
                              onTap: () => _handleSuggestionTap(question),
                            ),
                          )
                          .toList(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Divider
          const Divider(height: 1),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText:
                            "Ask about workouts, meal plans, or health tips...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 64,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "FitBot Assistant",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your personal fitness companion. Ask me anything about workouts, nutrition, hydration, sleep, and more!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ..._controller.initialSuggestions.map(
                  (question) => ActionChip(
                    label: Text(question),
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _handleSuggestionTap(question),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
