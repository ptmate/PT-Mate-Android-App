import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';

class AvatarSquare extends StatefulWidget {
  final String label;
  final double size;
  final String image;
  final double font;
  const AvatarSquare(this.label, this.size, this.image, this.font);
  @override
  _AvatarSquareState createState() => _AvatarSquareState();
}

class _AvatarSquareState extends State<AvatarSquare> {
  String label = "";
  double size = 0;
  String image = "";
  String img = "";
  double font = 0;

  void initState() {
    super.initState();
    if (!mounted) return;
    setState(() {
      label = widget.label;
      size = widget.size;
      image = widget.image;
      font = widget.font;
    });
    if (image != "") {
      getImage();
    }
  }

  void getImage() async {
    final ref = FirebaseStorage.instance.ref().child(image);
    var url = await ref.getDownloadURL();
    if (!mounted) return;
    setState(() {
      img = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (img == "") {
      return Container(
        padding: EdgeInsets.fromLTRB(0, (size - font) / 2 - (font / 8), 0, 0),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.075),
          color: AppColors.AvatarColor,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.WhiteColor,
            fontWeight: FontWeight.w700,
            fontSize: font,
          ),
        ),
      );
    } else {
      return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.075),
            color: AppColors.AvatarColor,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.075),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(img), fit: BoxFit.cover),
                  //fit: BoxFit.fill),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.075),
                  color: AppColors.AvatarColor,
                ),
              )));
    }
  }
}
