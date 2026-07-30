import 'package:flutter/material.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/main.dart';

class ListComment extends StatelessWidget {
  final String label;
  final String sublabel;
  final String image;
  final String text;
  final String right;
  final String avatar;

  ListComment(this.label, this.sublabel, this.image, this.text, this.right, this.avatar);

  String getInitials() {
    String inits = "";
    var arr = label.split(" ");
    for (var item in arr) {
      if (item != "") {
        inits += item[0];
      }
    }
    if (inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
        width: double.maxFinite,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(0, 5, 15, 0),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17.0),
                  color: AppColors.AvatarColor,
                ),
                child: Avatar(getInitials(), 34, image, 16, avatar),
              ),
              Column(children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  width: MediaQuery.of(context).size.width - 155,
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
                Container(
                    width: MediaQuery.of(context).size.width - 155,
                    child: Text(
                      sublabel,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.AvatarColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width - 155,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: SelectableText(
                      text,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 14,
                      ),
                    )),
                
              ]),
              Container (
                  width: 60,
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.topRight,
                  child: Text(
                    right,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.PrimaryColor,
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  )
                ),
            ]));
  }
}
