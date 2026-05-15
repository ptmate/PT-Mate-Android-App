import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class ListText extends StatelessWidget {
  final String label;
  final String sublabel;

  ListText(this.label, this.sublabel);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,5),
      height: 85,
      width: double.maxFinite,

      child: Column(
        children: <Widget> [
          Container (
            margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
            width: MediaQuery.of(context). size. width-55,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Container (
            width: MediaQuery.of(context). size. width-55,
            child: Text(
              sublabel,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            )
          ),
        ]
      )    
    );
  }
}