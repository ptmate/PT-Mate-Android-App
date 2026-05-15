import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class SubtitleLabel extends StatelessWidget {
  final String label;

  SubtitleLabel(this.label);
  
  @override
  Widget build(BuildContext context) {
    return Container (
      padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
      width: double.maxFinite,
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}