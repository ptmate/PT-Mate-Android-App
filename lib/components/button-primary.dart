import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class BtnPrimary extends StatelessWidget {
  final label;
  final clickFn;

  BtnPrimary({this.label, this.clickFn}) : super();
  
  @override
  Widget build(BuildContext context) {
    return Material (
      color: AppColors.PrimaryColor,
      borderRadius: BorderRadius.circular(22.5),
      clipBehavior: Clip.antiAlias,
      child: Container (
        height: 45,
        width: MediaQuery.of(context).size.width - 40,
        
        child: InkWell (
          onTap: () {
            clickFn();
          },
          child: Container (
            padding: EdgeInsets.only(top: 10),
            child: Text (
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.WhiteColor,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            )
          )
          
        )
      )
    );
  }
}
