import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'dart:math';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/components/button-group.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:ptmate_client/init/success.dart';
import 'package:ptmate_client/account/avatar.dart';


class RegisterPage extends StatefulWidget {
  static _RegisterPageState appState = _RegisterPageState();
  @override
  _RegisterPageState createState() {
    return RegisterPage.appState = new _RegisterPageState();
  }
}


class _RegisterPageState extends State<RegisterPage> {


  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _field5 = TextEditingController();
  TextEditingController _fieldEC1 = TextEditingController();
  TextEditingController _fieldEC2 = TextEditingController();
  bool accepted = false;
  bool newImage = true;
  var _image;
  var imgSelected = false;
  var spaces = [];
  var connects = [];
  int country = 0;
  List<String> cnames = ["Australia", "New Zealand", "United States"];
  List<String> ccodes = ["au", "nz", "us"];
  int type = 99;
  String unit = "cm";
  ModelSpace space = ModelSpace("", "", "", "", "", "", "", "", "", "", [], [], [], true, true, true, false, "", "", 0, 0, false, false, "default", "", [], false, "", 24, "", [], false, false, "au", false, "", false, true, false, "", "", false, true, "", 0, 0, false, [], []);
  final picker = ImagePicker();
  var connect = "";
  var client = "";
  var sid = "";
  var stype = "";
  var avatar = "";


  @override
  void initState() {
    super.initState();
    _field5.text = cnames[country];
    Connector.getConnect();
    Connector.getTrainers();
    Random random = new Random();
    int randomNumber = random.nextInt(GlobalUI.avatars.length);
    setState(() {
      avatar = GlobalUI.avatars[randomNumber];
    });
  }


  updateData() {
    if(this.mounted) {
      setState(() {
        spaces = GlobalData.allspaces;
        connects = GlobalData.connect;
      });
      if(spaces.length > 0 && connects.length > 0) {
        connect = "";
        client = "";
        sid = "";
        for(var item in connects) {
          if(item.email == GlobalUser.email) {
            connect = item.id;
            client = item.client;
            sid = item.space;
          }
        }

        for(var item2 in spaces) {
          if(item2.id == sid) {
            space = item2;
          }
        }
        var add = true;
        for(var item3 in GlobalData.spaces) {
          if(item3.id == space.id) {
            add = false;
          }
        }
        if(add) {
          GlobalData.spaces.add(space);
          Connector.getSpaceToken(GlobalData.spaces[GlobalData.spaces.length - 1]);
        }
        GlobalData.space = space;

        stype = "";
        if(GlobalData.space.showForms && GlobalData.space.pre != "") {
          Connector.getForms();
          stype = "form";
        }
      }

      // Clean up connect
      var sp = "";
      var cl = "";
      if(GlobalData.connect.length > 0) {
        for(var item in GlobalData.connect) {
          if(item.email == GlobalUser.email) {
            sp = item.space;
            cl = item.client;
            Connector.checkClients(sp, cl);
          }
        }
      }
      
    }
  }


  updateAvatar() {
    if(this.mounted) {
      setState(() {
        avatar = avatar;
        newImage = true;
        imgSelected = false;
      });
    }
  }


  _updateType1() { setState(() { type = 0; }); }
  _updateType2() { setState(() { type = 1; }); }
  _updateType3() { setState(() { type = 2; }); }


  _selectLocation(id) {
    if(id != "Location") {
      var tmp = 2;
      var un = "ft";
      if(id == "Australia") {
        tmp = 0;
        un = "cm";
      } else if(id == "New Zealand") {
        tmp = 1;
        un = "cm";
      }
      setState(() {
        country = tmp;
        unit = un;
      });
    }
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
    } else {
      DateFormat dt = DateFormat("dd MMMM yyyy");
      var bd = dt.parse(_field3.text);
      var nd = new DateTime(DateTime.now().year-18, DateTime.now().month, DateTime.now().day);
      if(bd.isAfter(nd)) {
        text += "You must be 18 years or older\n";
      }
    }
    if(_field4.text == "") {
      text += "Your height\n";
    }
    if(!accepted) {
      text += "Accept the Terms & Conditions and Privacy Policy";
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
    if(_field1.text != "" && _field2.text != "" && _field3.text != "" && _field4.text != "" && accepted && _field1.text.contains(" ")) {
      GlobalUser.name = _field1.text;
      GlobalUser.phone = _field2.text;
      DateTime tmpb1 = GlobalUI.dateFull.parse(_field3.text);
      String tmpb2 = GlobalUI.date.format(tmpb1);
      GlobalUser.birth = tmpb2;
      GlobalUser.height = int.parse(_field4.text);
      if(country == 1) {
        var ar = _field4.text.split(".");
        var h1 = double.parse(ar[0])*12.0*2.54;
        var h2 = 0.0;
        if(ar.length > 1) {
          h2 = double.parse(ar[1])*2.54;
        }
        GlobalUser.height = (h1+h2).toInt();
      }
      GlobalUser.ecName = _fieldEC1.text;
      GlobalUser.ecPhone = _fieldEC2.text;
      GlobalUser.ecType = type;
      GlobalUser.country = ccodes[country];
      FirebaseSender.createUser(_field1.text, _field2.text, tmpb2, GlobalUser.height, ccodes[country], _fieldEC1.text, _fieldEC2.text, type);
      if(newImage) {
        if(newImage) {
          if(avatar == "" && imgSelected) {
            GlobalUser.image = "images/users/"+GlobalUser.uid+".jpg";
            GlobalUser.avatar = "";
            FirebaseSender.updateUserImage(_image);
          } else if(avatar == "" && !imgSelected) {
            FirebaseSender.updateUserAvatar("", "");
            GlobalUser.avatar = "";
          } else if(avatar != "") {
            FirebaseSender.updateUserAvatar(avatar, "");
            GlobalUser.avatar = avatar;
          }
        }
      }

      if(connect == "") {
        Navigator.push(context, PageRoutes.sharedAxis(()=>TrainerPage(false), SharedAxisTransitionType.horizontal));
      } else {
        for(var item2 in spaces) {
          if(item2.id == sid) {
            space = item2;
          }
        }
        GlobalUI.isSignup = true;
        if(space.id != "" && space != null) {
          FirebaseSender.connectSpace(space, sid, client, _fieldEC1.text, _fieldEC2.text, type);
          FirebaseSender.deleteConnect(connect);
          if(GlobalData.space.showForms && GlobalData.space.pre != "") {
            stype = "form";
          }
          Navigator.push(context, PageRoutes.sharedAxis(()=>SuccessPage(stype), SharedAxisTransitionType.horizontal));
        }
      }
    } else {
      showAlert();
    }
  }


  tapAccept() {
    setState(() {
      accepted = true;
    });
  }


  _openURL() async {
    var url = "https://www.ptmate.net/mobile/terms-conditions";
    if(country == 1) {
      url = "https://www.ptmate.net/mobile/terms-conditions/us";
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  _selectDate(BuildContext context) async {
    var date = DateFormat("dd MMMM yyyy");
    final picked = await showDatePicker(
      context: context,
      initialDate: date.parse("01 January 1990"),
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
                  "Almost there",
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
                    "Just a few more details to set you up",
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
                      suffix: Text(unit),
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: Container (
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: cnames[country],
                      selectedItemBuilder: (BuildContext context) {
                        return cnames.map((String value) {
                          return Container(
                            padding: EdgeInsets.only(top: 13),
                              child: Text(
                              value,
                              style: TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w300),
                            )
                          );
                        }).toList();
                      },
                      items: cnames
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.BgColorDark,
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      style: TextStyle(color: AppColors.textColor),
                      onChanged: (String? newValue) {
                        _selectLocation(newValue);
                        /*setState(() {
                          product = newValue!;
                        });*/
                      },
                    )
                  ),
                ),

                // Emergency Contact

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
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
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

                Container ( 
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 0, 15, 40),
                        child: InkWell (
                          onTap: () {
                            tapAccept();
                          },
                          child: SvgPicture.asset(accepted ? "assets/images/list/terms-on.svg" : "assets/images/list/terms-off.svg", width: 30, height: 30)
                        )
                      ),
                      InkWell (
                        onTap: () {
                          _openURL();
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
      //return SvgPicture.asset("assets/images/common/no-image.svg", width: 110, height: 110);
      return ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Image.asset("assets/images/avatar/avatar-"+avatar+".jpg", width: 110, height: 110)
      );
    } else {
      /*return ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Container (
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(_image),
              fit: BoxFit.cover),
              //fit: BoxFit.fill),
          ),
        )
      );*/
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => AvatarPage("register")),);
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
