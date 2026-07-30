import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';


class ListHabit extends StatelessWidget {
  final String label;
  final String sublabel;
  final String right;
  final Color col;

  ListHabit(this.label, this.sublabel, this.right, this.col);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10,0,10,5),
      height: 70,
      width: double.maxFinite,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: <Widget> [
              Container (
                margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                width: MediaQuery.of(context). size. width-180,
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
                width: MediaQuery.of(context). size. width-180,
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
          ),
          Container(
            padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
            margin: EdgeInsets.fromLTRB(14, 12, 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: col,
            ),
            child: Text(
              right.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Quicksand",
                color: AppColors.WhiteColor,
                fontSize: 10,
              ),
            )
          )
        ]
      )

      /*child: Column(
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
      )  */ 
    );
  }
}