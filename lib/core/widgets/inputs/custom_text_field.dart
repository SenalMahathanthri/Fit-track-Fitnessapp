// lib/core/widgets/inputs/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
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
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
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
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            initialValue: widget.initialValue,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.isPassword && _obscureText,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            style: AppTextStyles.bodyLarge,
            cursorColor: AppColors.primaryBlue,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              counterText: "",
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
              suffixIcon:
                  widget.isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                      : widget.suffixIcon != null
                      ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: widget.onSuffixIconPressed,
                      )
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
