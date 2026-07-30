import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/calendar/leaderboard.dart';


class TitleDoubleLabel extends StatelessWidget {
  final String label;
  final String sublabel;
  final String right;
  final String session;
  final String block;

  TitleDoubleLabel(this.label, this.sublabel, this.right, this.session, this.block);
  
  @override
  Widget build(BuildContext context) {
    if(right == "") {
      return Container (
        padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
        width: double.maxFinite,
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              sublabel,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.AvatarColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        )
      );
    } else {
      Color col = AppColors.GreenColor;
      if(right == "RESULTS PENDING") {
        col = AppColors.OrangeColor;
      }
      if(right == "PENDING") {
        col = AppColors.FieldColor;
      }
      if(right == "UP NEXT") {
        col = AppColors.PrimaryColor;
      }
      Widget wright = Container();
      var img = "assets/images/nav/activity.svg";
      if(GlobalData.space.showHabits && right == "results" && GlobalData.space.comments) {
        img = "assets/images/nav/leaderboard.svg";
      }
      wright = IconButton(
        icon: SvgPicture.asset(img, width: 30, height: 30, color: AppColors.PrimaryColor,),
        iconSize: 30,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LeaderboardPage(session, block, right)),
          );
        },
      );
      if(right == "DONE" || right == "UP NEXT" || right == "PENDING") {
        wright = Container(
          padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
          margin: EdgeInsets.only(left: 14),
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
        );
      }
      return Container (
        padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
        width: double.maxFinite,
        child: Row (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container (
              width: MediaQuery.of(context).size.width-140,
              child:Column (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sublabel,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.AvatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            wright
          ],
        )
      );
    }
  }
    
}