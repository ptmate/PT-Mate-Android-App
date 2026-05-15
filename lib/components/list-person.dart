import 'package:flutter/material.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/main.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ListPerson extends StatelessWidget {
  
  final String label;
  final String sublabel;
  final String image;
  final String right;
  final String avatar;

  ListPerson(this.label, this.sublabel, this.image, this.right, this.avatar);


  String getInitials() {
    String inits = "";
    var arr = label.split(" ");
    for(var item in arr) {
      if(item != "") {
        inits += item[0];
      }
    }
    if(inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,5),
      height: 60,
      width: double.maxFinite,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container (
            margin: EdgeInsets.only(right: 15),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.0),
              color: AppColors.AvatarColor,
            ),
            child: Avatar(getInitials(), 34, image, 16, avatar),
          ),
          Column(
            children: <Widget> [
              Container (
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                width: MediaQuery.of(context). size. width-175,
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
                width: MediaQuery.of(context). size. width-175,
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
          getRight()
        ]
      )
      
    );
  }


  getRight() {
    if(right.contains("react-")) {
      return (
        Container(
          padding: EdgeInsets.all(4),
          child: SvgPicture.asset("assets/images/list/"+right+".svg", width: 20, height: 20),
        )
      );
    } else {
      return (
        Container (
          width: 75,
          padding: EdgeInsets.only(top: 10),
          alignment: Alignment.topRight,
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.PrimaryColor,
              fontFamily: "Oswald",
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          )
        )
      );
    }
  }
}