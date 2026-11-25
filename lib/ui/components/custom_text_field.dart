import 'package:flutter/material.dart';

import 'package:save_pass/ui/colors.dart';
import 'package:save_pass/ui/text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.suffix,
    required this.controller,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autovalidateMode,
  });

  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? suffix;
  final BorderRadius borderRadius;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppColors.accent,
      style: AppTextStyle.bodyText1,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autovalidateMode: autovalidateMode,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.black800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        suffixIcon: suffix,
        hintText: hintText,
        hintStyle: AppTextStyle.bodyText1.copyWith(color: AppColors.gray500),
        errorStyle: AppTextStyle.caption.copyWith(color: AppColors.red),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: AppColors.gray500.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 2,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
