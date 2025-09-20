import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final IconData leftIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField ({
    Key? key,
    required this.hint,
    required this.leftIcon,
    this.label,
    this.suffix,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black38),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0, horizontal: 16.0
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(
            left: 8.0, right: 8.0
          ),
          padding: const EdgeInsets.all(10.0),
          child: Icon(leftIcon, color: Colors.black54, size: 20),
        ),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.black87, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.indigo.shade700, width: 1.0),
        ),
        filled: true,
        fillColor: Colors.white,
        hoverColor: Colors.transparent,
      ),
    );
  }
}