import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/image_resolver.dart';

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
      img = ImageUrlResolver.isValidRemoteUrl(widget.image) ? widget.image : "";
      font = widget.font;
    });
    if (image != "") {
      getImage();
    }
  }

  void getImage() async {
    final url = await ImageUrlResolver.resolveUrl(image, contextTag: 'AvatarSquare');
    if (!mounted) return;
    if (url != null) {
      setState(() {
        img = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final decImage = ImageUrlResolver.safeDecorationImage(img, fit: BoxFit.cover);
    if (img == "" || decImage == null) {
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
                  image: decImage,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.075),
                  color: AppColors.AvatarColor,
                ),
              )));
    }
  }
}
