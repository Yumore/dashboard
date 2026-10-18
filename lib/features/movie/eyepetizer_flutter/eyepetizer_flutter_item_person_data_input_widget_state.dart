import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_person_data_input_widget.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterItemPersonDataInputWidget].
class EyepetizerFlutterItemPersonDataInputWidgetState
    extends State<EyepetizerFlutterItemPersonDataInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 80,
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.defaultText,
            ),
          ),
        ),
      ],
    );
  }
}
