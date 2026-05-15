import 'package:flutter/material.dart';

import 'package:ptmate_client/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/components/card-simple.dart';
import 'package:ptmate_client/init/login-login.dart';
import 'package:ptmate_client/init/login-register.dart';


class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
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
            padding: EdgeInsets.fromLTRB(20, 90, 20, 30),
            child: Column (
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                  //padding: EdgeInsets.all(15),
                  width: 110,
                  height: 110,
                  child: SvgPicture.asset("assets/images/common/logo-blue.svg", width: 110, height: 110),
                ),
                Text(
                  "PT Mate\nMember App",
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
                    "Please choose an option",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginLoginPage()),);
                  },
                  child: CardSimple("Log in", "If you have an account", "", "user.svg"),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRegisterPage()),);
                  },
                  child: CardSimple("Create an account", "It’s completely free", "-vividgreen", "user-add.svg"),
                ),
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      )
    );
  }
}