import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class TitleLabel extends StatelessWidget {
  final String label;
  final bool auto;

  TitleLabel(this.label, this.auto);
  
  @override
  Widget build(BuildContext context) {
    return Container (
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: this.auto ? null : double.maxFinite,
      child: Text(
        label,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w300,
          fontSize: 40,
        ),
      ),
    );
  }
}