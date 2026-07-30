import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';


class ListDefault extends StatelessWidget {
  final String label;
  final String sublabel;
  final String smalllabel;
  final String color;
  final String image;
  final bool numbers;

  ListDefault(this.label, this.sublabel, this.smalllabel, this.color, this.image, this.numbers);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,5),
      height: 112,
      width: double.maxFinite,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container (
            margin: EdgeInsets.fromLTRB(0, 15, 15, 0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                image: AssetImage("assets/images/common/gradient"+color+".png"),
                fit: BoxFit.cover,
              ),
            ),
            child: _configureCircle(),
          ),
          Column(
            children: <Widget> [
              Container (
                margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                width: MediaQuery.of(context). size. width-115,
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
                width: MediaQuery.of(context). size. width-115,
                child: Text(
                  sublabel,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                )
              ),
              Container (
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                width: MediaQuery.of(context). size. width-115,
                child: getSmall()
              )
            ]
          )
          
        ]
      )
      
    );
  }


  _configureCircle() {
    if(numbers) {
      return Container (
        padding: EdgeInsets.only(top: 9),
        child: Text(
          image,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.WhiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        )
      );
    } else {
      return SvgPicture.asset("assets/images/list/"+image, width: 40, height: 40);
    }
  }


  Widget getSmall() {
    if(smalllabel == "Booked in" || smalllabel.contains(" Booked in") || smalllabel.contains("attended") || smalllabel == "Active") {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: AppColors.GreenColor,
            ),
            child: Text(
              smalllabel.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Quicksand",
                color: AppColors.WhiteColor,
                fontSize: 10,
              ),
            )
          )
        ],
      );
    } else if(smalllabel == "Waiting list"|| smalllabel.contains(" on waiting list") || smalllabel.contains("Paused until") || smalllabel.contains("Expire")) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: AppColors.OrangeColor,
            ),
            child: Text(
              smalllabel.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Quicksand",
                color: AppColors.WhiteColor,
                fontSize: 10,
              ),
            )
          )
        ],
      );
    } else if(smalllabel.contains("Starts")) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: AppColors.fieldColor,
            ),
            child: Text(
              smalllabel.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Quicksand",
                color: AppColors.WhiteColor,
                fontSize: 10,
              ),
            )
          )
        ],
      );
    } else {
      return Text(
        smalllabel,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 10,
        ),
      );
    }
  }
}