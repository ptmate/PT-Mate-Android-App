import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/init/success.dart';


class SetupPage extends StatefulWidget {
  _SetupPageState createState() => _SetupPageState();
}


class _SetupPageState extends State<SetupPage> {


  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _fieldPass1 = TextEditingController();
  TextEditingController _fieldPass2 = TextEditingController();
  bool accepted = false;
  bool newImage = false;
  var _image;
  final picker = ImagePicker();


  @override
  void initState() {
    super.initState();
  }


  showAlert() {
    var text = "";
    if(_field1.text == "" || !_field1.text.contains(" ")) {
      text = "Your full name\n";
    }
    if(_field2.text == "") {
      text += "Your phone number\n";
    }
    if(_field3.text == "") {
      text += "Your date of birth\n";
    }
    if(_field4.text == "") {
      text += "Your height\n";
    }
    if(!accepted) {
      text += "Accept the Terms & Conditions and Privacy Policy\n";
    }
    if(_fieldPass1.text == "") {
      text += "Choose a password\n";
    }
    if(_fieldPass1.text != _fieldPass2.text) {
      text += "Password and repeat password fields don't match";
    }
    AlertDialog alert = AlertDialog(
      title: Text("Please review the following"),
      content: Text(text),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () { Navigator.of(context).pop(); },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  tapNext() {
    var passed = false;
    if(_field1.text != "" && _field2.text != "" && _field3.text != "" && _field4.text != "" && accepted && _field1.text.contains(" ") && _fieldPass1.text != "") {
      passed = true;
    }
    if(_fieldPass1.text != _fieldPass2.text) {
      passed = false;
    }
    if(passed && GlobalData.spaces[0].id != "" && GlobalData.spaces[0] != null) {
      GlobalUser.name = _field1.text;
      GlobalUser.phone = _field2.text;
      GlobalUser.birth = _field3.text;
      GlobalUser.height = int.parse(_field4.text);

      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(email: GlobalUser.email, password: "ptmate");
      user.reauthenticateWithCredential(cred).then((value) {
        user.updatePassword(_fieldPass1.text).then((_) {
          //Success, do something
        }).catchError((error) {
          //Error, show something
        });
      }).catchError((error) {
        //Error, show something
      });

      GlobalUI.isSignup = true;
      FirebaseSender.createUser(_field1.text, _field2.text, _field3.text, _field4.text, "au", "", "", 99);
      FirebaseSender.connectSpace(GlobalData.spaces[0], GlobalData.spaces[0].id, GlobalData.spaces[0].client, "", "", 99);
      if(newImage) {
        GlobalUser.image = "images/users/"+GlobalUser.uid+".jpg";
        FirebaseSender.updateUserImage(_image);
      }
      GlobalData.space = GlobalData.spaces[0];
      Navigator.push(context, PageRoutes.sharedAxis(()=>SuccessPage(""), SharedAxisTransitionType.horizontal));
    } else {
      showAlert();
    }
  }


  tapAccept() {
    setState(() {
      accepted = true;
    });
  }


  _openURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  _selectDate(BuildContext context) async {
    var date = DateFormat("dd/MM/yyyy");
    final picked = await showDatePicker(
      context: context,
      initialDate: date.parse("01/01/1990"),
      firstDate: DateTime(1940, 8),
      lastDate: DateTime.now());
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          _field3.text = date.format(picked);
        });
      }
    
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: MediaQuery(child: Container(
          color: AppColors.bgColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Column (
              children: [
                Text(
                  "Welcome aboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 40,
                  ),
                ),
                Container (
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                  width: double.maxFinite,
                  child: Text(
                    "Now let's get you all set with PT Mate",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container (
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 60),
                  child: Container (
                    padding: EdgeInsets.all(5),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60.0),
                      color: AppColors.PrimaryColor,
                    ),
                    child: InkWell(
                      onTap: () {
                        chooseImage();
                      },
                      child: getImageView()
                    ),
                  )
                ),
                
                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.name,
                    controller: _field1,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Your full name*',
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    onChanged: (text) {
                      //_updateSec(text);
                    },
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _field2,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Your phone number*',
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _field3,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Your date of birth*',
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    )
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _field4,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Your height*',
                      suffix: Text("cm"),
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    obscureText: true,
                    controller: _fieldPass1,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Choose a password*',
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    obscureText: true,
                    controller: _fieldPass2,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Repeat your password*',
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                  )
                ),

                Container (
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 0, 15, 30),
                        child: InkWell (
                          onTap: () {
                            tapAccept();
                          },
                          child: SvgPicture.asset(accepted ? "assets/images/list/terms-on.svg" : "assets/images/list/terms-off.svg", width: 30, height: 30)
                        )
                      ),
                      InkWell (
                        onTap: () {
                          _openURL("https://www.ptmate.net/mobile/terms-conditions");
                        },
                        child: Text(
                          "I have read and accept the\n> Terms & Conditions and Privacy Policy.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  )
                ),

                BtnPrimary(label: "Let's go", clickFn: tapNext)
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      ),
    );
  }


  getImageView() {
    if(!newImage) {
      return SvgPicture.asset("assets/images/common/no-image.svg", width: 110, height: 110);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Container (
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(_image),
              fit: BoxFit.cover),
              //fit: BoxFit.fill),
          ),
        )
      );
    }
  }


  chooseImage() {
    AlertDialog alert = AlertDialog(
      title: Text("Add a profile image"),
      content: Text("Please choose an option"),
      actions: [
        TextButton(
          child: Text("Take a picture"),
          onPressed: () {
            pickImageCamera();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Select from library"),
          onPressed: () {
            pickImageLibrary();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () { Navigator.of(context).pop(); },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Future pickImageCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 65, maxHeight: 800, maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {
          newImage = true;
        });
      } else {
        print('No image selected.');
      }
    });
  }


  Future pickImageLibrary() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxHeight: 800, maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {
          newImage = true;
        });
      } else {
        print('No image selected.');
      }
    });
  }
}