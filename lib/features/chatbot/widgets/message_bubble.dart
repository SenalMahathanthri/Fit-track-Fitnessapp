import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessage;

  const MessageBubble({
    super.key,
    required this.message,
    this.isLastMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar (only show for bot messages)
          if (!message.isUser) _buildAvatar(),

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color:
                    message.isUser ? AppColors.primaryBlue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      message.formattedTime,
                      style: TextStyle(
                        color:
                            message.isUser
                                ? Colors.white.withOpacity(0.7)
                                : Colors.black54,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User avatar (only show for user messages) - optional
          if (message.isUser) _buildUserDot(),
        ],
      ),
    );
  }

  // Bot avatar widget
  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
        radius: 18,
        child: const Icon(
          Icons.fitness_center,
          color: AppColors.primaryBlue,
          size: 18,
        ),
      ),
    );
  }

  // Simple dot for user messages (optional)
  Widget _buildUserDot() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
