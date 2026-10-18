import 'package:flutter/material.dart';

import 'flutterwechatfull_style.dart';

/// The source's `MHTextField`: a borderless 17sp field with a grey hint.
class FlutterWechatFullTextField extends StatelessWidget {
  const FlutterWechatFullTextField({
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.maxLength,
    this.keyboardType,
    this.autofocus = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: FlutterWechatFullStyle.primary,
      style: const TextStyle(
        fontSize: 17.0,
        color: FlutterWechatFullStyle.textPrimary,
      ),
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
      ),
    );
  }
}
