import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/image_resolver.dart';


class Avatar extends StatefulWidget {

  final String label;
  final double size;
  final String image;
  final double font;
  final String avatar;
  const Avatar(this.label, this.size, this.image, this.font, this.avatar);
  @override
  _AvatarState createState() => _AvatarState();
}


class _AvatarState extends State<Avatar> {
  
  
  String label = "";
  double size = 0;
  String image = "";
  String img = "";
  double font = 0;
  String avatar = "";


  void initState() {
    super.initState();
    setState(() {
      label = widget.label;
      size = widget.size;
      image = widget.image;
      img = ImageUrlResolver.isValidRemoteUrl(widget.image) ? widget.image : "";
      font = widget.font;
      avatar = widget.avatar;
    });
    if(image != "") {
      getImage();
    }
    
  }


  void getImage() async {
    final url = await ImageUrlResolver.resolveUrl(image, contextTag: 'Avatar');
    if (url != null && mounted) {
      setState(() {
        img = url;
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final decImage = ImageUrlResolver.safeDecorationImage(img, fit: BoxFit.cover);
    if(img == "" || decImage == null) {
      if(avatar == "") {
        return Container (
          padding: EdgeInsets.fromLTRB(0, (size-font)/2-(font/8), 0, 0),
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size/2),
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
        return Container (
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size/2),
            color: AppColors.AvatarColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size/2),
            child: Image.asset("assets/images/avatar/avatar-"+avatar+".jpg", width: size, height: size)
          )
        );
      }
    } else {
      return Container (
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size/2),
          color: AppColors.AvatarColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size/2),
          child: Container (
            foregroundDecoration: BoxDecoration(
              image: decImage,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size/2),
              color: AppColors.AvatarColor,
            ),
          )
        )
      );
    }
    
  }
}