import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';


class CardText extends StatelessWidget {
  final String label;
  final String sublabel;
  final String small;

  CardText(this.label, this.sublabel, this.small);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,5),
      //height: 85,
      width: double.maxFinite,

      child: Card(
        elevation: 3,
        color: AppColors.boxColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
            Container (
              margin: EdgeInsets.fromLTRB(20, 13, 20, 5),
              width: MediaQuery.of(context).size.width-100,
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
              margin: EdgeInsets.fromLTRB(20, 0, 20, 15),
              width: MediaQuery.of(context).size.width-100,
              child: Text(
                sublabel,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 14,
                ),
              )
            ),
            getSmall(small)
          ]
        )
      ),
      
    );
  }


  getSmall(small) {
    if(small != "") {
      return (
        Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
          child: Text(
            small,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 11,
            ),
          )
        )
      );
    } else {
      return Container();
    }
  }
}