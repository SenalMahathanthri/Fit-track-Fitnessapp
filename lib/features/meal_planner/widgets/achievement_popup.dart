// lib/views/meal_planner/widgets/achievement_popup.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AchievementPopup extends StatefulWidget {
  final String title;
  final String description;
  final int points;
  final VoidCallback onClose;

  const AchievementPopup({
    super.key,
    required this.title,
    required this.description,
    required this.points,
    required this.onClose,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation and auto-dismiss after delay
    _controller.forward();
    _setupAutoDismiss();
  }

  void _setupAutoDismiss() {
    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismissPopup();
      }
    });
  }

  void _dismissPopup() {
    _controller.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissPopup,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildPopupContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopupContent() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B3AFF), Color(0xFF3A6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Achievement badge/animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Trophy icon with glow effect
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.emoji_events, color: Colors.white, size: 60),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Confetti animation
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Colors.yellow, Colors.orange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            child: Text(
              "Achievement Unlocked!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                foreground:
                    Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.yellow, Colors.orange],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Achievement title
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Achievement description
          Text(
            widget.description,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Points badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  "+${widget.points} points",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Close button
          ElevatedButton(
            onPressed: _dismissPopup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Got it!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
