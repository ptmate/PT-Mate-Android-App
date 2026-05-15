import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';


class CalculatorPage extends StatefulWidget {
  final double val;
  const CalculatorPage(this.val);
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}


class _CalculatorPageState extends State<CalculatorPage> {


  double val = 0;
  bool active = true;
  TextEditingController txt = TextEditingController();


  @override
  void initState() {
    bool tactive = true;
    String ttxt = "";
    if(widget.val > 0) {
      tactive = false;
      ttxt = widget.val.toString();
    }
    super.initState();
    txt.text = ttxt;
    setState(() {
      val = widget.val;
      active = tactive;
      //txt = ttxt;
    });
  }
  
  void _updateValue(value) {
    double num = 0;
    if(value != "") {
      num = double.parse(value);
    }
    setState(() {
      val = num;
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("% Calculator"),
            ),
            
            // Textfield
            Container (
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: txt,
                autofocus: active,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Enter a weight',
                  suffix: Text((GlobalData.space.lbs ? 'lb' : 'kg')),
                  suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                  labelStyle: TextStyle(color: AppColors.textColor),
                ),
                inputFormatters: [
                  //WhitelistingTextInputFormatter(RegExp('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'))
                  FilteringTextInputFormatter.allow(RegExp('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'))
                ],
                onChanged: (text) {
                  _updateValue(text);
                },
              )
            ),
            // Scrollbar
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: _getListings(),
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

  _getListings() {
    List<Widget> listings = [];
    int i = 0;
    for (i = 1; i < 10; i++) {
      final double v1 = val*(1-i*0.1+0.05);
      final double v2 = val*(1-i*0.1);
      listings.add(
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2 - 20,
              child: DataLabel((100-i*10+5).toString()+"%", val == 0 ? "-" : v1.toStringAsFixed(1)+" "+(GlobalData.space.lbs ? 'lb' : 'kg'))
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2 - 20,
              child: DataLabel((100-i*10).toString()+"%", val == 0 ? "-" : v2.toStringAsFixed(1)+" "+(GlobalData.space.lbs ? 'lb' : 'kg'))
            ),
          ],
        )
        
      );
    }
     return listings;
  }

}