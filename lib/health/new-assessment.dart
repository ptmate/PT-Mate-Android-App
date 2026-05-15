import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ptmate_client/_data/client.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';


class NewAssessmentPage extends StatefulWidget {
  final String id;
  const NewAssessmentPage(this.id);

  static _NewAssessmentPageState appState = _NewAssessmentPageState();
  @override
  _NewAssessmentPageState createState(){
    return NewAssessmentPage.appState = new _NewAssessmentPageState();
  }
}


class _NewAssessmentPageState extends State<NewAssessmentPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _field11 = TextEditingController();
  TextEditingController _field12 = TextEditingController();
  TextEditingController _field13 = TextEditingController();
  TextEditingController _field14 = TextEditingController();
  TextEditingController _field15 = TextEditingController();
  TextEditingController _field16 = TextEditingController();
  TextEditingController _field17 = TextEditingController();
  TextEditingController _field18 = TextEditingController();
  TextEditingController _blood1 = TextEditingController();
  TextEditingController _blood2 = TextEditingController();
  TextEditingController _custom = TextEditingController();
  bool newImage = false;
  bool newImage2 = false;
  bool newImage3 = false;
  bool newImage4 = false;
  bool expanded = false;
  String imgOrig = "";
  String imgOrig2 = "";
  String imgOrig3 = "";
  String imgOrig4 = "";
  String img = "";
  String img2 = "";
  String img3 = "";
  String img4 = "";
  String id = "";
  String subtitle = "";
  String dt = "";
  var _image;
  var _image2;
  var _image3;
  var _image4;
  int imgNum = 1;
  var unit = "cm";
  final picker = ImagePicker();


  String mutateCreate(id, date, time, weight) {
    return('''
      mutation createWeight {
        insert_weights_one(object: {created_at: "$time", date_recorded: "$date", updated_at: "$time", u_weight: $weight, user_id: $id, weight: $weight}) {
          id
        }
      }
    ''');
  }


  String mutateUpdate(id, user, time, weight) {
    return('''
      mutation updateWeight {
        update_weights_by_pk(pk_columns: {id: $id},
        _set: {
          updated_at: "$time",
          user_id: $user,
          weight: $weight,
          u_weight: $weight,
        })
        {
          id
        }
      }
    ''');
  }


  String mutateUserUpdate(id, weight) {
    return('''
      mutation updateUserWeight {
        update_users_by_pk(pk_columns: {id: $id},
          _set: {
              current_weight: $weight,
              u_current_weight: $weight,
          })
        {
          id
          current_weight
        }
      }
    ''');
  }


  @override
  void initState() {
    super.initState();
    var un = "cm";
    if(GlobalData.space.lbs) {
      un = "in";
    }
    setState(() {
      id = widget.id;
      unit = un;
    });

    var tf2 = DateFormat('dd/MM/yyyy HH:mm');

    if(id != '') {
      for(var item in GlobalData.assessments) {
        if(item.id == id) {
          _field1.text = item.weight.toStringAsFixed(1);
          if(GlobalUser.lbs) {
            _field1.text = (item.weight*GlobalUI.lbsUp).toStringAsFixed(1);
          }
          _field2.text = item.fat.toStringAsFixed(1);
          _field3.text = item.heart.toString();
          _field4.text = item.notes;
          imgOrig = item.image;
          imgOrig2 = item.image2;
          imgOrig3 = item.image3;
          imgOrig4 = item.image4;

          _field11.text = item.neck.toStringAsFixed(1);
          _field12.text = item.chest.toStringAsFixed(1);
          _field13.text = item.abdomen.toStringAsFixed(1);
          _field14.text = item.hip.toStringAsFixed(1);
          _field15.text = item.armL.toStringAsFixed(1);
          _field16.text = item.armR.toStringAsFixed(1);
          _field17.text = item.thighL.toStringAsFixed(1);
          _field18.text = item.thighR.toStringAsFixed(1);

          _blood1.text = item.blood1;
          _blood2.text = item.blood2;
          _custom.text = item.custom;

          if(GlobalUser.lbs) {
            _field11.text = (item.neck/2.54).toStringAsFixed(1);
            _field12.text = (item.chest/2.54).toStringAsFixed(1);
            _field13.text = (item.abdomen/2.54).toStringAsFixed(1);
            _field14.text = (item.hip/2.54).toStringAsFixed(1);
            _field15.text = (item.armL/2.54).toStringAsFixed(1);
            _field16.text = (item.armR/2.54).toStringAsFixed(1);
            _field17.text = (item.thighL/2.54).toStringAsFixed(1);
            _field18.text = (item.thighR/2.54).toStringAsFixed(1);
          }

          var show = false;
          if(item.neck != 0) {show = true;}
          if(item.chest != 0) {show = true;}
          if(item.abdomen != 0) {show = true;}
          if(item.hip != 0) {show = true;}
          if(item.armL != 0) {show = true;}
          if(item.armR != 0) {show = true;}
          if(item.thighL != 0) {show = true;}
          if(item.thighR != 0) {show = true;}

          setState(() {
            subtitle = HelperCal.getSpecialDateYear(item.date);
            expanded = show;
            dt = tf2.format(item.date);;
          });
        }
      }
      
    }
  }


  _tapCreate() {
    var weight = (double.tryParse(_field1.text) == null ? 0 : double.parse(_field1.text));
    if(weight > 0 && GlobalUser.lbs) {
      var tmp = (weight/GlobalUI.lbsUp).toStringAsFixed(2);
      weight = double.parse(tmp);
    }
    var fat = (double.tryParse(_field2.text) == null ? 0 : double.parse(_field2.text));
    var heart = (int.tryParse(_field3.text) == null ? 0 : int.parse(_field3.text));
    var notes = _field4.text;
    var neck = (double.tryParse(_field11.text) == null ? 0 : double.parse(_field11.text));
    var chest = (double.tryParse(_field12.text) == null ? 0 : double.parse(_field12.text));
    var abdomen = (double.tryParse(_field13.text) == null ? 0 : double.parse(_field13.text));
    var hip = (double.tryParse(_field14.text) == null ? 0 : double.parse(_field14.text));
    var armL = (double.tryParse(_field15.text) == null ? 0 : double.parse(_field15.text));
    var armR = (double.tryParse(_field16.text) == null ? 0 : double.parse(_field16.text));
    var thighL = (double.tryParse(_field17.text) == null ? 0 : double.parse(_field17.text));
    var thighR = (double.tryParse(_field18.text) == null ? 0 : double.parse(_field18.text));

    var bl1 = _blood1.text;
    var bl2 = _blood2.text;
    var cus = _custom.text;

    if(GlobalUser.lbs) {
      neck = double.parse((neck*2.54).toStringAsFixed(1));
      chest = double.parse((chest*2.54).toStringAsFixed(1));
      abdomen = double.parse((abdomen*2.54).toStringAsFixed(1));
      hip = double.parse((hip*2.54).toStringAsFixed(1));
      armL = double.parse((armL*2.54).toStringAsFixed(1));
      armR = double.parse((armR*2.54).toStringAsFixed(1));
      thighL = double.parse((thighL*2.54).toStringAsFixed(1));
      thighR = double.parse((thighR*2.54).toStringAsFixed(1));
    }

    var image = "";
    var key = FirebaseSender.createAssessmentId();
    
    var tf = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var time = tf.format(DateTime.now());

    var tf1 = DateFormat('yyyy-MM-dd');
    var time1 = tf1.format(DateTime.now());

    var tf2 = DateFormat('dd/MM/yyyy HH:mm');
    var date= tf2.format(DateTime.now());

    if(GlobalData.space.nutritionId != "" && weight != 0) {
      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: Config.link,
      );
      client.mutate(
        MutationOptions(
          document: gql(mutateCreate(int.parse(GlobalData.space.nutritionId), time1, time, weight)),
          onCompleted: (dynamic resultData) {
            FirebaseSender.updateAssessment(key, weight, fat, heart, notes, neck, chest, abdomen, hip, armL, armR, thighL, thighR, image, resultData["insert_weights_one"]["id"], date, bl1, bl2, cus);
            /*if(newImage) {
              FirebaseSender.updateImage(key, _image);
            }*/
            if(newImage) {
              FirebaseSender.updateImage(key, key, _image, "image");
            }
            if(newImage2) {
              FirebaseSender.updateImage(key, key+"-2", _image2, "image2");
            }
            if(newImage3) {
              FirebaseSender.updateImage(key, key+"-3", _image3, "image3");
            }
            if(newImage4) {
              FirebaseSender.updateImage(key, key+"-4", _image4, "image4");
            }
          }
        ),
      );
      client.mutate(
        MutationOptions(
          document: gql(mutateUserUpdate(int.parse(GlobalData.space.nutritionId), weight)),
        ),
      );
    } else {
      FirebaseSender.updateAssessment(key, weight, fat, heart, notes, neck, chest, abdomen, hip, armL, armR, thighL, thighR, image, "", date, bl1, bl2, cus);
      /*if(newImage) {
        FirebaseSender.updateImage(key, _image);
      }*/
      if(newImage) {
        FirebaseSender.updateImage(key, key, _image, "image");
      }
      if(newImage2) {
        FirebaseSender.updateImage(key, key+"-2", _image2, "image2");
      }
      if(newImage3) {
        FirebaseSender.updateImage(key, key+"-3", _image3, "image3");
      }
      if(newImage4) {
        FirebaseSender.updateImage(key, key+"-4", _image4, "image4");
      }
    }
    _showConfirmation("Entry successfully created");

    FirebaseSender.sendPushMessage(GlobalData.space.token, "New health log", GlobalUser.name+" just logged a new assessment.", "client", GlobalData.space.client, []);
  }


  _tapUpdate() { 
    var weight = (double.tryParse(_field1.text) == null ? 0 : double.parse(_field1.text));
    if(weight > 0 && GlobalUser.lbs) {
      var tmp = (weight/GlobalUI.lbsUp).toStringAsFixed(2);
      weight = double.parse(tmp);
    }
    var fat = (double.tryParse(_field2.text) == null ? 0 : double.parse(_field2.text));
    var heart = (int.tryParse(_field3.text) == null ? 0 : int.parse(_field3.text));
    var notes = _field4.text;
    var neck = (double.tryParse(_field11.text) == null ? 0 : double.parse(_field11.text));
    var chest = (double.tryParse(_field12.text) == null ? 0 : double.parse(_field12.text));
    var abdomen = (double.tryParse(_field13.text) == null ? 0 : double.parse(_field13.text));
    var hip = (double.tryParse(_field14.text) == null ? 0 : double.parse(_field14.text));
    var armL = (double.tryParse(_field15.text) == null ? 0 : double.parse(_field15.text));
    var armR = (double.tryParse(_field16.text) == null ? 0 : double.parse(_field16.text));
    var thighL = (double.tryParse(_field17.text) == null ? 0 : double.parse(_field17.text));
    var thighR = (double.tryParse(_field18.text) == null ? 0 : double.parse(_field18.text));

    var bl1 = _blood1.text;
    var bl2 = _blood2.text;
    var cus = _custom.text;

    if(GlobalUser.lbs) {
      neck = double.parse((neck*2.54).toStringAsFixed(1));
      chest = double.parse((chest*2.54).toStringAsFixed(1));
      abdomen = double.parse((abdomen*2.54).toStringAsFixed(1));
      hip = double.parse((hip*2.54).toStringAsFixed(1));
      armL = double.parse((armL*2.54).toStringAsFixed(1));
      armR = double.parse((armR*2.54).toStringAsFixed(1));
      thighL = double.parse((thighL*2.54).toStringAsFixed(1));
      thighR = double.parse((thighR*2.54).toStringAsFixed(1));
    }

    var image = imgOrig;

    var tf = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var time = tf.format(DateTime.now());
    var nutrition = "";
    for(var item in GlobalData.assessments) {
      if(item.id == id) {
        nutrition = item.nutrition;
        if(item.nutrition != "") {
          GraphQLClient client = GraphQLClient(
            cache: GraphQLCache(),
            link: Config.link,
          );
          client.mutate(
            MutationOptions(
              document: gql(mutateUpdate(int.parse(nutrition), int.parse(GlobalData.space.nutritionId), time, weight)),
            ),
          );

          if(id == GlobalData.assessments[0].id) {
            client.mutate(
              MutationOptions(
                document: gql(mutateUserUpdate(int.parse(GlobalData.space.nutritionId), weight)),
              ),
            );
          }

        }
      }
    }

    FirebaseSender.updateAssessment(id, weight, fat, heart, notes, neck, chest, abdomen, hip, armL, armR, thighL, thighR, image, nutrition, dt, bl1, bl2, cus);
    /*if(newImage) {
      FirebaseSender.updateImage(id, _image);
    }*/
    if(newImage) {
      FirebaseSender.updateImage(id, id, _image, "image");
    }
    if(newImage2) {
      FirebaseSender.updateImage(id, id+"-2", _image2, "image2");
    }
    if(newImage3) {
      FirebaseSender.updateImage(id, id+"-3", _image3, "image3");
    }
    if(newImage4) {
      FirebaseSender.updateImage(id, id+"-4", _image4, "image4");
    }

    _showConfirmation("Entry successfully updated");
  }


  _showConfirmation(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
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
              child: TitleLabelBack((id == '' ? 'New Log Entry' : 'Edit Log Entry')),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 20),
              child: Text(
                subtitle,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            //width: (double.maxFinite-40)/2,
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: InkWell(
                              onTap: () {
                                chooseImage(1);
                              },
                              child: getImageView(newImage, imgOrig, img, _image, 1)
                            ),
                          )
                        ),
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            //width: (double.maxFinite-40)/2,
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: InkWell(
                              onTap: () {
                                chooseImage(2);
                              },
                              child: getImageView(newImage2, imgOrig2, img2, _image2, 2)
                            ),
                          )
                        )
                      ],
                    ),

                    Row(
                      children: [
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 60),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            //width: (double.maxFinite-40)/2,
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: InkWell(
                              onTap: () {
                                chooseImage(3);
                              },
                              child: getImageView(newImage3, imgOrig3, img3, _image3, 3)
                            ),
                          )
                        ),
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            //width: (double.maxFinite-40)/2,
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: InkWell(
                              onTap: () {
                                chooseImage(4);
                              },
                              child: getImageView(newImage4, imgOrig4, img4, _image4, 4)
                            ),
                          )
                        )
                      ],
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
                        controller: _field1,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Weight',
                          suffixText: (GlobalUser.lbs ? "lb" : "kg"),
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
                          labelText: 'Body fat percentage',
                          suffixText: '%',
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
                        controller: _field3,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Rest heart rate',
                          suffixText: "bpm",
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
                        controller: _blood1,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Blood pressure (Systolic)',
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
                        controller: _blood2,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Blood pressure (Diastolic)',
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
                        controller: _custom,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Custom value',
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
                        keyboardType: TextInputType.name,
                        controller: _field4,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Notes',
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    ),

                    _getMore(),
                    Container(height: 30),
                    _getButton()
                    
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


  _getButton() {
    if(id == '') {
      return (
        BtnPrimary(label: "Create log entry", clickFn: _tapCreate)
      );
    } else {
      return (
        BtnPrimary(label: "Update log entry", clickFn: _tapUpdate)
      );
    }
  }


  _getMore() {
    if(expanded) {
      return (
        Column(
          children: [
            BtnTertiary(label: "Hide more options", clickFn: _toggleExpanded),

            Container (
              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
              width: double.maxFinite,
              child: Text(
                'Segmental circumference',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 24,
                ),
              ),
            ),

            Container (
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _field11,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Neck',
                  suffixText: unit,
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
                controller: _field12,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Chest',
                  suffixText: unit,
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
                controller: _field13,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Abdomen',
                  suffixText: unit,
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
                controller: _field14,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Hip',
                  suffixText: unit,
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
                controller: _field15,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Left arm',
                  suffixText: unit,
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
                controller: _field16,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Right arm',
                  suffixText: unit,
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
                controller: _field17,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Left thigh',
                  suffixText: unit,
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
                controller: _field18,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Right thigh',
                  suffixText: unit,
                  suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                  labelStyle: TextStyle(color: AppColors.textColor),
                ),
                onChanged: (text) {
                  //_updateSec(text);
                },
              )
            ),
          ],
        )
        
      );
    } else {
      return (
        BtnTertiary(label: "Show more options", clickFn: _toggleExpanded)
      );
    }
  }


  _toggleExpanded() {
    if(expanded) {
      setState(() {
        expanded = false;
      });
    } else {
      setState(() {
        expanded = true;
      });
    }
  }


  getImageView(vn, vio, vimg, vi, num) {
    //if(!newImage && imgOrig != "") {
    if(!vn && vio != "") {
      getImage(num);
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container (
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(vimg),
              fit: BoxFit.contain),
              //fit: BoxFit.fill),
          ),
        )
      );
    //} else if(!newImage && imgOrig == "") {
    } else if(!vn && vio == "") {
      return SvgPicture.asset("assets/images/common/no-image-trans.svg", width: 110, height: 110);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container (
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(vi),
              fit: BoxFit.contain),
              //fit: BoxFit.fill),
          ),
        )
      );
    }
  }


  void getImage(number) async {
    /*final ref = FirebaseStorage.instance.ref().child(imgOrig);
    var url = await ref.getDownloadURL();
    setState(() {
      img = url;
    });*/
    if(number == 1) {
      final ref = FirebaseStorage.instance.ref().child(imgOrig);
      var url = await ref.getDownloadURL();
      setState(() {
        img = url;
      });
    } else if(number == 2) {
      final ref = FirebaseStorage.instance.ref().child(imgOrig2);
      var url = await ref.getDownloadURL();
      setState(() {
        img2 = url;
      });
    } else if(number == 3) {
      final ref = FirebaseStorage.instance.ref().child(imgOrig3);
      var url = await ref.getDownloadURL();
      setState(() {
        img3 = url;
      });
    } else if(number == 4) {
      final ref = FirebaseStorage.instance.ref().child(imgOrig4);
      var url = await ref.getDownloadURL();
      setState(() {
        img4 = url;
      });
    }
  }


  chooseImage(number) {
    setState(() {
      imgNum = number;
    });
    AlertDialog alert = AlertDialog(
      title: Text("Add an image"),
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
        if(imgNum == 1) {
          _image = File(pickedFile.path);
          setState(() {
            newImage = true;
          });
        } else if(imgNum == 2) {
          _image2 = File(pickedFile.path);
          setState(() {
            newImage2 = true;
          });
        } else if(imgNum == 3) {
          _image3 = File(pickedFile.path);
          setState(() {
            newImage3 = true;
          });
        } else if(imgNum == 4) {
          _image4 = File(pickedFile.path);
          setState(() {
            newImage4 = true;
          });
        }

      } else {
        print('No image selected.');
      }
    });
  }


  Future pickImageLibrary() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxHeight: 800, maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        if(imgNum == 1) {
          _image = File(pickedFile.path);
          setState(() {
            newImage = true;
          });
        } else if(imgNum == 2) {
          _image2 = File(pickedFile.path);
          setState(() {
            newImage2 = true;
          });
        } else if(imgNum == 3) {
          _image3 = File(pickedFile.path);
          setState(() {
            newImage3 = true;
          });
        } else if(imgNum == 4) {
          _image4 = File(pickedFile.path);
          setState(() {
            newImage4 = true;
          });
        }
      } else {
        print('No image selected.');
      }
    });
  }

}