import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';


class ListShopping extends StatelessWidget {
  
  final String label;
  final String sublabel;
  final String image;
  final bool right;

  ListShopping(this.label, this.sublabel, this.image, this.right);

  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,5),
      height: 60,
      width: double.maxFinite,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container (
            margin: EdgeInsets.only(right: 8),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.0),
            ),
            child: SvgPicture.asset(image, width: 34, height: 34),
          ),
          Column(
            children: <Widget> [
              Container (
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                width: MediaQuery.of(context). size. width-135,
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
              Container (
                width: MediaQuery.of(context). size. width-135,
                child: Text(
                  sublabel,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                )
              ),
            ]
          ),
          Container (
            width: 34,
            height: 34,
            alignment: Alignment.topRight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.0),
              color: (right ? AppColors.GreenColor : AppColors.fieldColor)
            ),
            child: getTick()
          ),
        ]
      )
      
    );
  }


  getTick() {
    if(right) {
      return SvgPicture.asset('assets/images/list/plan-done.svg', width: 34, height: 34);
    } else {
      SvgPicture.asset('assets/images/common/empty.svg', width: 34, height: 34);
    }
  }
}