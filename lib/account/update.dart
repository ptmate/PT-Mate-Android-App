import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-group.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/account/avatar.dart';
import 'package:ptmate_client/main.dart';


class UpdatePage extends StatefulWidget {
  static _UpdatePageState appState = _UpdatePageState();
  @override
  _UpdatePageState createState(){
    return UpdatePage.appState = new _UpdatePageState();
  }
}


class _UpdatePageState extends State<UpdatePage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _field5 = TextEditingController();
  TextEditingController _fieldEC1 = TextEditingController();
  TextEditingController _fieldEC2 = TextEditingController();
  DateTime bstring = GlobalUI.date.parse(GlobalUser.birth);
  bool newImage = false;
  bool imgSelected = false;
  String img = "";
  String avatar = "";
  var _image;
  int type = 99;
  final picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _field1.text = GlobalUser.name;
    _field2.text = GlobalUser.phone;
    _field3.text = GlobalUI.dateFull.format(bstring);
    _field4.text = GlobalUser.height.toString();
    if(GlobalUser.lbs && GlobalUser.height > 0) {
      var b = GlobalUser.height/2.54;
      var h1 = (b/12).toInt();
      var h2 = (b-(h1*12)).toStringAsFixed(0);
      _field4.text = h1.toString()+"."+h2;
    }
    _field5.text = GlobalData.space.goal;
    _fieldEC1.text = GlobalUser.ecName;
    _fieldEC2.text = GlobalUser.ecPhone;
    type = GlobalUser.ecType;
  }


  updateData() {
    if(this.mounted) {
      setState(() {
        payments: GlobalData.payments;
      });
    }
  }


  updateAvatar() {
    if(this.mounted) {
      setState(() {
        avatar = avatar;
        newImage = true;
        img  = "";
        imgSelected = false;
      });
    }
  }


  _updateType1() { setState(() { type = 0; }); }
  _updateType2() { setState(() { type = 1; }); }
  _updateType3() { setState(() { type = 2; }); }


  _selectDate(BuildContext context) async {
    //var date = DateFormat("dd/MM/yyyy");
    var date = DateFormat("dd MMMM yyyy");
    final picked = await showDatePicker(
      context: context,
      initialDate: date.parse(_field3.text),
      firstDate: DateTime(1940, 8),
      lastDate: DateTime.now());
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          _field3.text = date.format(picked);
        });
      }
  }


  _tapUpdate() {
    if(_field1.text != "" && _field2.text != "" && _field3.text != "") {
      int height = 0;
      if(_field4.text != "") {
        if(GlobalUser.lbs) {
          var ar = _field4.text.split(".");
          var h1 = double.parse(ar[0])*12.0*2.54;
          var h2 = 0.0;
          if(ar.length > 1) {
            h2 = double.parse(ar[1])*2.54;
          }
          height = (h1+h2).toInt();
        } else {
          height = int.parse(_field4.text);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Details successfully updated"),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
        )
      );
      DateTime tmpb1 = GlobalUI.dateFull.parse(_field3.text);
      String tmpb2 = GlobalUI.date.format(tmpb1);
      FirebaseSender.updateUser(_field1.text, _field2.text, tmpb2, height, _field5.text, _fieldEC1.text, _fieldEC2.text, type);
      if(newImage) {
        if(avatar == "" && imgSelected) {
          FirebaseSender.updateUserImage(_image);
          GlobalUser.avatar = "";
        } else if(avatar == "" && !imgSelected) {
          FirebaseSender.updateUserAvatar("", GlobalData.space.id);
          GlobalUser.avatar = "";
        } else if(avatar != "") {
          FirebaseSender.updateUserAvatar(avatar, GlobalData.space.id);
          GlobalUser.avatar = avatar;
        }
        UpdatePage.appState.updateData();
      }
    } else {
      _showAlert();
    }
    
  }


  _showAlert() {
    String label = "";
    if(_field1.text == "") {
      label = "Your full name\n";
    }
    if(_field2.text == "") {
      label += "Your phone number\n";
    }
    if(_field3.text == "") {
      label += "Your date of birth";
    }
    AlertDialog alert = AlertDialog(
    title: Text("Please review the following"),
      content: Text(label),
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("Update"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
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
                          labelText: 'Full name*',
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
                          labelText: 'Phone*',
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
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            keyboardType: TextInputType.name,
                            controller: _field3,
                            style: TextStyle(color: AppColors.textColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Date of birth*',
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
                        keyboardType: TextInputType.name,
                        controller: _field4,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Height',
                          suffixText: (GlobalData.space.lbs ? 'ft' : 'cm'),
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
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.name,
                        controller: _field5,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Training focus',
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    ),

                    SubtitleLabel("Emergency contact"),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.name,
                        controller: _fieldEC1,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Name',
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
                        controller: _fieldEC2,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Phone',
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    ),

                    Container (
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: Row(
                        children: [
                          BtnGroup(label: 'Spouse', items: 3, active: (type == 0 ? true : false), clickFn: _updateType1,),
                          BtnGroup(label: 'Family', items: 3, active: (type == 1 ? true : false), clickFn: _updateType2,),
                          BtnGroup(label: 'Friend', items: 3, active: (type == 2 ? true : false), clickFn: _updateType3,),
                        ],
                      )
                    ),

                    BtnPrimary(label: "Update details", clickFn: _tapUpdate)
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  getImageView() {
    if(!newImage && GlobalUser.image != "") {
      getImage();
      return ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Container (
          foregroundDecoration: (img != "" && img.startsWith("http")) ? BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(img),
              fit: BoxFit.cover),
              //fit: BoxFit.fill),
          ) : null,
        )
      );
    } else if(!newImage && GlobalUser.image == "") {
      if(GlobalUser.avatar == "") {
        return SvgPicture.asset("assets/images/common/no-image.svg", width: 110, height: 110);
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(55),
          child: Image.asset("assets/images/avatar/avatar-"+GlobalUser.avatar+".jpg", width: 110, height: 110)
        );
      }
      
    } else {
      if(newImage && avatar != "") {
        return ClipRRect(
          borderRadius: BorderRadius.circular(55),
          child: Image.asset("assets/images/avatar/avatar-"+avatar+".jpg", width: 110, height: 110)
        );
      } else if(newImage && avatar == "" && imgSelected) {
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
      } else {
        return SvgPicture.asset("assets/images/common/no-image.svg", width: 110, height: 110);
      }
      
    }
  }


  void getImage() async {
    final ref = FirebaseStorage.instance.ref().child(GlobalUser.image);
    var url = await ref.getDownloadURL();
    setState(() {
      img = url;
    });
  }


  chooseImage() {
    AlertDialog alert = AlertDialog(
      title: Text("Update your profile image"),
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
          child: Text("Select from your library"),
          onPressed: () {
            pickImageLibrary();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Select from image gallery"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(builder: (context) => AvatarPage("update")),);
          },
        ),
        TextButton(
          child: Text("No image"),
          onPressed: () {
            selectNoImage();
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
          imgSelected = true;
          avatar = "";
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
          imgSelected = true;
          avatar = "";
        });
      } else {
        print('No image selected.');
      }
    });
  }


  selectNoImage() {
    setState(() {
      avatar = "";
      newImage = true;
      imgSelected = false;
      //_image = null;
    });
  }

}
