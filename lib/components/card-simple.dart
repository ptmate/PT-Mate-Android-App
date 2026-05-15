import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';


class CardSimple extends StatelessWidget {
  final String label;
  final String sublabel;
  final String color;
  final String image;

  CardSimple(this.label, this.sublabel, this.color, this.image);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,5),
      height: 105,
      width: double.maxFinite,

      child: Card(
        elevation: 3,
        color: AppColors.boxColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: <Widget>[
            Container (
              margin: EdgeInsets.all(15),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  image: AssetImage("assets/images/common/gradient"+color+".png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SvgPicture.asset("assets/images/list/"+image, width: 40, height: 40),
            ),
            Column(
              children: <Widget> [
                Container (
                  margin: EdgeInsets.fromLTRB(0, 17, 0, 5),
                  width: MediaQuery.of(context).size.width-140,
                  child: Text(
                    label,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container (
                  width: MediaQuery.of(context).size.width-140,
                  child: Text(
                    sublabel,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                    ),
                  )
                )
              ]
            )
            
          ]
        )
      ),
      
    );
  }
}