// CustomDropdownField widget
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CustomDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final List<String> items;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomDropdownField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    required this.items,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _isFocused
                      ? AppColors.primaryBlue
                      : widget.borderColor ?? Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow:
                _isFocused
                    ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: DropdownButtonFormField<String>(
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              prefixIcon:
                  widget.prefixIcon != null
                      ? Icon(
                        widget.prefixIcon,
                        color:
                            _isFocused
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                        size: 20,
                      )
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            value:
                widget.controller.text.isNotEmpty
                    ? widget.controller.text
                    : null,
            items:
                widget.items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTextStyles.bodyLarge),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                widget.controller.text = value ?? '';
              });
            },
            validator: widget.validator,
            dropdownColor: widget.backgroundColor ?? Colors.white,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
              size: 24,
            ),
            style: AppTextStyles.bodyLarge,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}
