// lib/common_widget/simple_animation_progress_bar.dart
import 'package:flutter/material.dart';

class SimpleAnimationProgressBar extends StatefulWidget {
  final double height;
  final double width;
  final Color backgroundColor;
  final Color foregrondColor;
  final double ratio;
  final Axis direction;
  final Curve curve;
  final Duration duration;
  final BorderRadius borderRadius;
  final Gradient? gradientColor;

  const SimpleAnimationProgressBar({
    super.key,
    required this.height,
    required this.width,
    required this.backgroundColor,
    required this.foregrondColor,
    required this.ratio, // Value between 0.0 and 1.0
    this.direction = Axis.horizontal,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 500),
    this.borderRadius = BorderRadius.zero,
    this.gradientColor,
  });

  @override
  State<SimpleAnimationProgressBar> createState() =>
      _SimpleAnimationProgressBarState();
}

class _SimpleAnimationProgressBarState extends State<SimpleAnimationProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.ratio).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(SimpleAnimationProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ratio != widget.ratio) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.ratio,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve),
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
          ),
          child: Stack(children: [_buildProgressIndicator(_animation.value)]),
        );
      },
    );
  }

  Widget _buildProgressIndicator(double value) {
    double progressHeight =
        widget.direction == Axis.vertical
            ? widget.height * value
            : widget.height;

    double progressWidth =
        widget.direction == Axis.horizontal
            ? widget.width * value
            : widget.width;

    Alignment beginAlignment =
        widget.direction == Axis.vertical
            ? Alignment.bottomCenter
            : Alignment.centerLeft;

    Alignment endAlignment =
        widget.direction == Axis.vertical
            ? Alignment.topCenter
            : Alignment.centerRight;

    return Align(
      alignment:
          widget.direction == Axis.vertical
              ? Alignment.bottomCenter
              : Alignment.centerLeft,
      child: Container(
        height: progressHeight,
        width: progressWidth,
        decoration: BoxDecoration(
          color: widget.gradientColor == null ? widget.foregrondColor : null,
          gradient: widget.gradientColor,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}
