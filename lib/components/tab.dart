import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';

class TabLabel extends StatelessWidget {
  final label;
  final active;
  final valueFn;
  final clickFn;

  //TabLabel({Key key, this.label, this.active, this.clickFn, this.valueFn}) : super(key: key);
  TabLabel({this.label, this.active, this.clickFn, this.valueFn}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          color: active ? AppColors.PrimaryColor : AppColors.boxColor,
        ),
        child: InkWell(
          onTap: () {
            clickFn(valueFn);
          },
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: active ? AppColors.boxColor : AppColors.textColor,
              fontWeight: active ? FontWeight.w700 : FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ));
  }
}
