import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class BtnTertiary extends StatelessWidget {
  final label;
  final clickFn;

  BtnTertiary({this.label, this.clickFn}) : super();
  
  @override
  Widget build(BuildContext context) {
    return Material (
      color: Colors.transparent,
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
                color: AppColors.PrimaryColor,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            )
          )
          
        )
      )
    );
  }
}