import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class DataLabelCol extends StatelessWidget {
  final String label;
  final String value;
  final double weight;
  

  DataLabelCol(this.label, this.value, this.weight);
  
  @override
  Widget build(BuildContext context) {
    return Container (
      padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
      width: weight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.45),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.left,
            
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 20,
            ),
          ),
        ],
      )
    );
  }
}