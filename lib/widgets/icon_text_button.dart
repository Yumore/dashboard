import 'package:flutter/material.dart';

class IconTextButton extends StatefulWidget {
  final Icon icon;
  final String title;
  final Function onTap;

  const IconTextButton(this.icon, this.title, this.onTap, {Key? key})
      : super(key: key);

  @override
  _IconTextButtonState createState() => _IconTextButtonState();
}

class _IconTextButtonState extends State<IconTextButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
          child: InkWell(
        onTap: () => widget.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.icon,
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(widget.title))
            ],
          ),
        ),
      )),
    );
  }
}
