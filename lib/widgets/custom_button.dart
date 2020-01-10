import 'package:flutter/material.dart';
import '../Data/constants.dart';

class CustomButton extends StatelessWidget {
  final Function ontap;
  final String text;
  final String buttonType;
  CustomButton({this.ontap, this.text, this.buttonType});
  @override
  Widget build(BuildContext context) {
    switch (buttonType) {
      case Constants.raisedButton:
        return RaisedButton(
          onPressed: ontap,
          child: Text(text),
        );
        break;
      case Constants.flatButton:
        return FlatButton(
          onPressed: ontap,
          child: Text(text),
        );
        break;
      default:
    }
  }
}
