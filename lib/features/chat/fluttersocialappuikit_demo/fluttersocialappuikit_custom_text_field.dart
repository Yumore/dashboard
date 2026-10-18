import 'package:flutter/material.dart';

/// Outlined form field of the FlutterSocialAppUIKit login screen
/// (source `lib/views/widgets/custom_text_field.dart`).
///
/// The source's field owns no state and only passes the usual `TextFormField`
/// hooks through; the port keeps the same parameter set and the same
/// [OutlineInputBorder] styling.
class FlutterSocialAppUIKitCustomTextField extends StatelessWidget {
  const FlutterSocialAppUIKitCustomTextField({
    this.initialValue,
    this.enabled,
    this.hintText,
    this.keyboardType,
    this.controller,
    this.textInputAction,
    this.focusNode,
    this.nextFocusNode,
    this.submitAction,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    super.key,
  });

  final String? initialValue;
  final bool? enabled;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback? submitAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onSaved;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        onChanged: onChanged,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        textInputAction: textInputAction,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 15.0),
        onFieldSubmitted: (String term) {
          if (nextFocusNode != null) {
            focusNode?.unfocus();
            FocusScope.of(context).requestFocus(nextFocusNode);
          } else {
            submitAction?.call();
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          border: _border(),
          focusedBorder: _border(),
          disabledBorder: _border(),
        ),
      ),
    );
  }

  OutlineInputBorder _border() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(color: Color(0xFFB3ABAB), width: 1.0),
    );
  }
}
