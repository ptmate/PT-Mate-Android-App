import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';


class DataToggle extends StatelessWidget {
  final String label;
  final bool value;
  

  DataToggle(this.label, this.value);
  
  @override
  Widget build(BuildContext context) {
    return Container (
      padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
      width: double.maxFinite,
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container (
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: _configureImage(context),
          ),
          
          Text(
            label,
            textAlign: TextAlign.left,
            
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 14,
            ),
          ),
        ],
      )
    );
  }


  _configureImage(context) {
    if(value == false) {
      var qdarkMode = MediaQuery.of(context).platformBrightness;
      if (qdarkMode == Brightness.dark){
        return (
          SvgPicture.asset('assets/images/common/toggle-off-dark.svg', width: 40, height: 20)
        );
      } else {
      return (
        SvgPicture.asset('assets/images/common/toggle-off.svg', width: 40, height: 20)
      );
      }
    } else {
      return (
        SvgPicture.asset('assets/images/common/toggle-on-'+GlobalData.space.theme+'.svg', width: 40, height: 20)
      );
    }
  }
}