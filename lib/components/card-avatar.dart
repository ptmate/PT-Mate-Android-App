import 'package:flutter/material.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/main.dart';

class CardAvatar extends StatelessWidget {
  final String label;
  final String sublabel;
  final String image;
  final String img = "";
  final double width;
  final double font;
  final String avatar;

  CardAvatar(this.label, this.sublabel, this.image, this.width, this.font,
      this.avatar);

  void getImage() async {
    /*final ref = FirebaseStorage.instance.ref().child('/images/users/'+GlobalData.space.id+'.jpg');
// no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();
    print(url);
    setState(() {
      image = url;
    });*/
  }

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
      // height: 105,
      width: double.maxFinite,

      child: Card(
          elevation: 3,
          color: AppColors.boxColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(children: <Widget>[
            Container(
              margin: EdgeInsets.all(15),
              child: Avatar(getInitials(), width, image, font, avatar),
            ),
            Column(children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                width: 200,
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
                  width: 200,
                  child: Text(
                    sublabel,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                    ),
                  ))
            ])
          ])),
    );
  }
}
