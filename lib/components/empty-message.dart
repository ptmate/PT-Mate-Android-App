import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/main.dart';

class EmptyMessage extends StatelessWidget {
  final String image;
  final String label;
  final String sublabel;

  EmptyMessage(this.image, this.label, this.sublabel);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 130, 0, 30),
        width: double.maxFinite,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          /*Container (
            padding: EdgeInsets.all(15),
            child: SvgPicture.asset("assets/images/illustration/"+GlobalData.space.theme+"/"+image+".svg", width: 300, height: 100),
          ),*/
          Container(
            //padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(bottom: 15),
            width: 300,
            height: 220,
            child: SvgPicture.asset(
                "assets/images/illustration/" +
                    image +
                    (GlobalUI.dark ? "-dark" : "") +
                    ".svg",
                width: 300,
                height: 220),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/illustration/circles-" +
                    GlobalData.space.theme +
                    (GlobalUI.dark ? "-dark" : "") +
                    ".png"),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.5),
              fontWeight: FontWeight.w300,
              fontSize: 24,
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          )
        ]));
  }
}
