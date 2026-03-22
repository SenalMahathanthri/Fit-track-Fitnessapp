// lib/core/widgets/custom_fancy_nav_bar.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomFancyNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomNavBarItem> items;

  const CustomFancyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CustomFancyNavBar> createState() => _CustomFancyNavBarState();
}

class _CustomFancyNavBarState extends State<CustomFancyNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomFancyNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the safe area bottom padding to account for iPhone home indicator
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // Increase height to account for bottom safe area
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // This replaces overflow: Overflow.visible
        alignment: Alignment.topCenter,
        children: [
          // Bottom nav bar items
          Padding(
            // Add padding at the bottom to move content above the home indicator
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),

          // Floating circle for active item
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: -30,
            left:
                MediaQuery.of(context).size.width /
                    widget.items.length *
                    widget.currentIndex +
                (MediaQuery.of(context).size.width / widget.items.length - 60) /
                    2,
            child: ScaleTransition(
              scale: _animation,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.items[widget.currentIndex].icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = index == widget.currentIndex;
    return InkWell(
      onTap: () => widget.onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width / widget.items.length,
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty space for icon when active (since active icon is in the floating circle)
            SizedBox(height: isActive ? 24 : 0),

            // Icon (only shown when not active)
            if (!isActive)
              Icon(widget.items[index].icon, color: AppColors.gray, size: 24),

            const SizedBox(height: 4),

            // Label
            Text(
              widget.items[index].title,
              style: TextStyle(
                color: isActive ? AppColors.primaryBlue : AppColors.gray,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNavBarItem {
  final IconData icon;
  final String title;

  CustomNavBarItem({required this.icon, required this.title});
}
