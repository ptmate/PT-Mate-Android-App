import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ptmate_client/_data/client.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/health/new-assessment.dart';
import 'package:ptmate_client/_helper/image_resolver.dart';


class AssessmentPage extends StatefulWidget {
  final String id;
  final ModelAssessment item;
  const AssessmentPage(this.id, this.item);

  static _AssessmentPageState appState = _AssessmentPageState();
  @override
  _AssessmentPageState createState(){
    return AssessmentPage.appState = new _AssessmentPageState();
  }
}


class _AssessmentPageState extends State<AssessmentPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String img = "";
  String img2 = "";
  String img3 = "";
  String img4 = "";
  String id = "";
  ModelAssessment item = ModelAssessment("", DateTime.now(), 0, 0, 0, "", "", 0, 0, 0, 0, 0, 0, 0, 0, "", "", "", "", "", "", "");
  var _image;


  String mutateDelete(id) {
    return('''
      delete_weights_by_pk(id: $id) {
        id
      }
    ''');
  }


  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
  }


  updateData() {
    if(this.mounted) {
      ModelAssessment tmp = ModelAssessment("", DateTime.now(), 0, 0, 0, "", "", 0, 0, 0, 0, 0, 0, 0, 0, "", "", "", "", "", "", "");
      for(var ass in GlobalData.assessments) {
        if(ass.id == id) {
          tmp = ass;
        }
      }
      setState(() {
        id = id;
        item = tmp;
      });
    }
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
              child: TitleLabelBack(('Log Entry')),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 20),
              child: Text(
                HelperCal.getSpecialDateYear(item.date),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: getImageView(item.image, img, 1),
                          )
                        ),
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: getImageView(item.image2, img2, 2),
                          )
                        ),
                      ]
                    ),

                    Row(
                      children: [
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 60),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: getImageView(item.image3, img3, 3),
                          )
                        ),
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                          child: Container (
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width/2-25,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.FieldColor,
                            ),
                            child: getImageView(item.image4, img4, 4),
                          )
                        ),
                      ]
                    ),

                    DataLabel('Weight', (item.weight == 0 ? '-' : _getWeight(item.weight))),
                    DataLabel('Body fat percentage', (item.fat == 0 ? '-' : item.fat.toStringAsFixed(1)+'%')),
                    DataLabel('Rest heart rate', (item.heart == 0 ? '-' : item.heart.toString()+' bpm')),
                    DataLabel('Blood pressure', ((item.blood1 == '' || item.blood2 == '') ? '-' : item.blood1+' / '+item.blood2)),
                    _getCustom(),
                    DataLabel('Notes', (item.notes == '' ? '-' : item.notes)),

                    _getMore(),
                    Container(height: 20),

                    BtnSecondarySmall(label: 'Edit', clickFn: _tapEdit,),
                    Container(height: 20),
                    BtnTertiary(label: 'Delete', clickFn: _tapDeleteAssessment,),
                    
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


  _getWeight(weight) {
    var label = weight.toStringAsFixed(1)+' kg';
    if(GlobalUser.lbs) {
      label = (weight*GlobalUI.lbsUp).toStringAsFixed(1)+' lb';
    }
    return label;
  }


  _getCustom() {
    if(item.custom != '') {
      return DataLabel('Custom value', item.custom);
    } else {
      return Container();
    }
  }


  _getMoreValue(value) {
    var label = value.toString()+' cm';
    if(GlobalUser.lbs) {
      label = ((value as double)/2.54).toStringAsFixed(1)+' in';
    }
    return label;
  }


  _getMore() {
    var show = false;
    if(item.neck != 0) {show = true;}
    if(item.chest != 0) {show = true;}
    if(item.abdomen != 0) {show = true;}
    if(item.hip != 0) {show = true;}
    if(item.armL != 0) {show = true;}
    if(item.armR != 0) {show = true;}
    if(item.thighL != 0) {show = true;}
    if(item.thighR != 0) {show = true;}
    if(show) {
      return (
        Column(
          children: [
            Container (
              padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
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

            DataLabel('Neck', (item.neck == 0 ? '-' : _getMoreValue(item.neck))),
            DataLabel('Chest', (item.chest == 0 ? '-' : _getMoreValue(item.chest))),
            DataLabel('Abdomen', (item.abdomen == 0 ? '-' : _getMoreValue(item.abdomen))),
            DataLabel('Hip', (item.hip == 0 ? '-' : _getMoreValue(item.hip))),
            DataLabel('Left arm', (item.armL == 0 ? '-' : _getMoreValue(item.armL))),
            DataLabel('Right arm', (item.armR == 0 ? '-' : _getMoreValue(item.armR))),
            DataLabel('Left thigh', (item.thighL == 0 ? '-' : _getMoreValue(item.thighL))),
            DataLabel('Right thigh', (item.thighR == 0 ? '-' : _getMoreValue(item.thighR))),
          ]
        )
      );
    } else {
      return Container();
    }
  }


  _tapEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewAssessmentPage(id)),);
  }


  _tapDeleteAssessment() {
    AlertDialog alert = AlertDialog(
      title: Text("Delete this log entry?"),
      content: Text("Are you sure you want to delete this health log entry?"),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deleteAssessment();
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


  deleteAssessment() {
    FirebaseSender.deleteAssessment(id);
    if(item.nutrition != "") {
      GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: Config.link,
      );
      client.mutate(
        MutationOptions(
          document: gql(mutateDelete(int.parse(item.nutrition)),
        ),
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Health log successfully deleted"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }


  getImageView(iimage, iimg, num) {
    if(iimage != "") {
      if (iimg == "") {
        getImage(num);
      }
      final decImage = ImageUrlResolver.safeDecorationImage(iimg, fit: BoxFit.contain);
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container (
          foregroundDecoration: decImage != null ? BoxDecoration(image: decImage) : null,
        )
      );
    } else {
      return SvgPicture.asset("assets/images/common/no-image-basic.svg", width: 110, height: 110);
    }
  }


  void getImage(number) async {
    String target = "";
    if(number == 1) {
      target = item.image;
    } else if(number == 2) {
      target = item.image2;
    } else if(number == 3) {
      target = item.image3;
    } else if(number == 4) {
      target = item.image4;
    }

    if (target.isEmpty) return;
    final url = await ImageUrlResolver.resolveUrl(target, contextTag: 'Assessment_$number');
    if (url != null && mounted) {
      setState(() {
        if(number == 1) {
          img = url;
        } else if(number == 2) {
          img2 = url;
        } else if(number == 3) {
          img3 = url;
        } else if(number == 4) {
          img4 = url;
        }
      });
    }
  }

}