import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class BtnGroup extends StatelessWidget {
  final label;
  final active;
  final items;
  final clickFn;

  BtnGroup({this.label, this.items, this.active, this.clickFn}) : super();
  
  @override
  Widget build(BuildContext context) {
    return Material (
      color: AppColors.fieldColor,
      clipBehavior: Clip.antiAlias,
      child: Container (
        height: 40,
        width: (MediaQuery.of(context).size.width-44)/items,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          color: (active ? AppColors.boxColor : AppColors.fieldColor),
        ),
        child: InkWell (
          onTap: () {
            clickFn();
          },
          child: Container (
            padding: EdgeInsets.only(top: 10),
            child: Text (
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: (active ? FontWeight.w600 : FontWeight.w400),
                fontSize: 16,
              ),
            )
          )
          
        )
      )
    );
  }
}