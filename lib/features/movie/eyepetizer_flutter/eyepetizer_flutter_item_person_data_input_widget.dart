import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_person_data_input_widget_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/widgets/item_person_data_input_widget.dart` →
/// `ItemPersonDataInputWidget`.
///
/// One labelled, pre-filled text field of the edit-profile form.
class EyepetizerFlutterItemPersonDataInputWidget extends StatefulWidget {
  const EyepetizerFlutterItemPersonDataInputWidget({
    super.key,
    required this.title,
    this.defaultText,
    this.controller,
  });

  final String title;
  final String? defaultText;
  final TextEditingController? controller;

  @override
  State<EyepetizerFlutterItemPersonDataInputWidget> createState() =>
      EyepetizerFlutterItemPersonDataInputWidgetState();
}
