import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/variables.dart';


class EmptyLabel extends StatelessWidget {
  final String image;
  final String label;
  String dark = "";

  EmptyLabel(this.image, this.label);
  
  @override
  Widget build(BuildContext context) {
    if(GlobalUI.dark) {
      dark = "-dark";
    }
    if(image == "") {
      return Container (
        padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
        width: double.maxFinite,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textColor.withOpacity(0.5),
            fontWeight: FontWeight.w300,
            fontSize: 24,
          ),
        ),
      );
    } else {
      return Column(
        children: [
          Container (
            padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
            width: double.maxFinite,
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                SvgPicture.asset("assets/images/empty/"+image+dark+".svg", width: 100, height: 100),
                SvgPicture.asset("assets/images/empty/"+image+"-color.svg", width: 100, height: 100, color: AppColors.PrimaryColor),
              ],
            ),
          ),
          
          Container (
            padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
            width: double.maxFinite,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor.withOpacity(0.5),
                fontWeight: FontWeight.w300,
                fontSize: 22,
              ),
            ),
          )
        ],
      );
    }
  }
}