import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class BtnTertiarySmall extends StatelessWidget {
  final label;
  final clickFn;

  BtnTertiarySmall({this.label, this.clickFn}) : super();
  
  @override
  Widget build(BuildContext context) {
    return Material (
      color: Colors.transparent,
      child: InkWell (
          onTap: () {
            clickFn();
          },
          child: Text (
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.PrimaryColor,
              fontFamily: "Oswald",
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          )
          
        )
    );
  }
}