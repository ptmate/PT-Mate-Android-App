import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';

class TitleLabelBack extends StatelessWidget {
  final String label;

  TitleLabelBack(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      width: double.maxFinite,
      child: Row(children: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/nav/header-back.svg",
            width: 30,
            height: 30,
            color: AppColors.PrimaryColor,
          ),
          iconSize: 30,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w300,
              fontSize: 40,
            ),
          ),
        ),
      ]),
    );
  }
}
