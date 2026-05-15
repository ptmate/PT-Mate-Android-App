import 'package:flutter/material.dart';

import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';


class ProductPage extends StatefulWidget {
  final String name;
  final String desc;
  const ProductPage(this.name, this.desc);
  static _ProductPageState appState = _ProductPageState();
  @override
  _ProductPageState createState(){
    return ProductPage.appState = new _ProductPageState();
  }
}


class _ProductPageState extends State<ProductPage> {


  String name = "";
  String desc = "";


  @override
  void initState() {
    super.initState();
    setState(() {
      name = widget.name;
      desc = widget.desc;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("Product Info"),
            ),
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
              width: double.maxFinite,
              child: Text(
                name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              width: double.maxFinite,
              child: Text(
                desc,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 14,
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

}