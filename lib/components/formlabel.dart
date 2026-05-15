import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class FormLabel extends StatelessWidget {
  final String label;

  FormLabel(this.label);
  
  @override
  Widget build(BuildContext context) {
    return Container (
      padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
      width: double.maxFinite,
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget> [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.45),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ]
      )
    );
  }
}