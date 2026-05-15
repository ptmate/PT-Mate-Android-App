import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class BtnSecondarySmall extends StatelessWidget {
  final label;
  final clickFn;

  BtnSecondarySmall({this.label, this.clickFn}) : super();
  
  @override
  Widget build(BuildContext context) {
    return Material (
      color: AppColors.PrimaryColor.withOpacity(0.3),
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: Container (
        height: 30,
        width: 170,
        
        child: InkWell (
          onTap: () {
            clickFn();
          },
          child: Container (
            padding: EdgeInsets.only(top: 4),
            child: Text (
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.PrimaryColor,
                fontFamily: "Oswald",
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            )
          )
          
        )
      )
    );
  }
}