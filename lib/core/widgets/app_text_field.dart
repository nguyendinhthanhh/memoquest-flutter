import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcon,
    this.textInputAction,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
