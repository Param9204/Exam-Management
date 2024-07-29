import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType; // Added parameter

  CustomTextField({
    required this.controller,
    required this.labelText,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text, // Default to TextInputType.text
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType, // Apply keyboardType
    );
  }
}
