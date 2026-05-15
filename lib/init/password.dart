import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';

class PasswordPage extends StatefulWidget {
  static _PasswordPageState appState = _PasswordPageState();
  @override
  _PasswordPageState createState() {
    return PasswordPage.appState = new _PasswordPageState();
  }
}

class _PasswordPageState extends State<PasswordPage>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _field = TextEditingController();

  _sendReset() async {
    if (_field.text != "" &&
        _field.text.contains("@") &&
        _field.text.contains(".")) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _field.text);
        print("Reset email sent");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print("No user exists with this email");
        } else {
          print("Error: ${e.message}");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("We just sent you an email"),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
      ));

      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
          color: AppColors.bgColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TitleLabelBack("Reset password"),
              ),

              // Textfield
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(20, 50, 20, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _field,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Your email address',
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                  )),

              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Text(
                    "Enter your email address. We'll send you a link to reset your password.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                    ),
                  )),

              // Button
              Expanded(
                  child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: BtnPrimary(
                          label: "RESET PASSWORD", clickFn: _sendReset)))
            ],
          ),
        ),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }
}
