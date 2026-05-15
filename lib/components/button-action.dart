import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class BtnAction extends StatelessWidget {
  final label1;
  final label2;
  final clickFn1;
  final clickFn2;

  BtnAction({this.label1, this.label2, this.clickFn1, this.clickFn2}) : super();
  
  @override
  Widget build(BuildContext context) {
    return Material (
      clipBehavior: Clip.antiAlias,
      child: Container (
        color: AppColors.bgColor,
        child: Row(
        
        children: [
          InkWell (
            onTap: () {
              clickFn1();
            },
            child: Container (
              margin: EdgeInsets.fromLTRB(0, 0, 10, 10),
              padding: EdgeInsets.all(10),
              width: (MediaQuery.of(context).size.width-50)/2,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.fieldColor,
              ),
              child: Text (
                label1,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
            ),
          ),
          InkWell (
            onTap: () {
              clickFn2();
            },
            child: Container (
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              padding: EdgeInsets.all(10),
              width: (MediaQuery.of(context).size.width-50)/2,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.fieldColor,
              ),
              child: Text (
                label2,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
            ),
          ),
        ]
      ))
    );
  }
}