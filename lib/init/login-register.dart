import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/register.dart';
import 'package:ptmate_client/init/select.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:ptmate_client/main.dart';

class LoginRegisterPage extends StatefulWidget {
  static _LoginRegisterPageState appState = _LoginRegisterPageState();
  _LoginRegisterPageState createState() {
    return LoginRegisterPage.appState = new _LoginRegisterPageState();
  }
}

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  int _spaces = 0;
  int _counter = 0;
  bool _active = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _active = true;
    });
  }

  @override
  void dispose() {
    // setState(() {
    _active = false;
    // });
    super.dispose();
  }

  _checkRegister() {
    if (_field1.text != "" && _field2.text != "") {
      setState(() {
        _loading = true;
      });
      _registerUser();
    } else {
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Can't log in"),
        content: Text("Please enter your email address and password."),
        actions: [
          okButton,
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  _registerUser() async {
    try {
      //var userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //await FirebaseAuth.instance.signInWithEmailAndPassword(
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _field1.text, password: _field2.text)
          .then((value) => getUserId());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showError('Wrong password provided for that user.');
      } else {
        showError(e.message);
      }
      setState(() {
        _loading = false;
      });
    }
  }

  updateTrainer(exists) {
    if (exists) {
    } else {}
  }

  Future<void> getUserId() async {
    GlobalUser.uid = FirebaseAuth.instance.currentUser!.uid;
    GlobalUser.email = FirebaseAuth.instance.currentUser!.email!;
    FirebaseAuth.instance.currentUser!.updateProfile(displayName: "Member");
    gotoNext("register");
  }

  _loginGoogle() {
    signInWithGoogle().then((result) {
      //if (result != null) {
      if (result != "") {
        //checkTrainer();
        Connector.checkTrainer(FirebaseAuth.instance.currentUser!.uid);
      } else {
        showError('No user found for that email.');
      }
    });
  }

  Future<String> signInWithGoogle() async {
    //final GoogleSignInAccount googleSignInAccount = await googleSignIn!.signIn();
    final googleSignInAccount = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      // accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user!;
    var token = await user.getIdToken();
    print("token ::: ${token}");

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser!;
    assert(user.uid == currentUser.uid);
    GlobalUser.uid = currentUser.uid;
    GlobalUser.email = currentUser.email!;

    return '$user';

    return "";
  }

  showError(message) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error creating account"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    setState(() {
      _loading = false;
    });
  }

  checkTrainer(exists) {
    //var exists = Connector.checkTrainer();
    if (!exists) {
      //if(FirebaseAuth.instance.currentUser!.displayName == "client" || FirebaseAuth.instance.currentUser!.displayName == "") {
      GlobalUser.uid = FirebaseAuth.instance.currentUser!.uid;
      GlobalUser.email = FirebaseAuth.instance.currentUser!.email!;
      Connector.getUser();
    } else {
      FirebaseAuth.instance.signOut();
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Trainer Account"),
        content: Text(
            "You just logged in with a Trainer account. Please download the PT Mate app from the App Store to log in."),
        actions: [
          okButton,
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      setState(() {
        _loading = false;
      });
    }
  }

  updateData() {
    if (this.mounted && _active) {
      if (GlobalUser.phone == "") {
        gotoNext("register");
      } else {
        setState(() {
          _spaces = GlobalUser.spaces;
        });
      }
    }
  }

  updateSpaces() {
    if (this.mounted && _active) {
      setState(() {
        _counter += 1;
      });
      if (_counter == GlobalUser.spaces) {
        if (GlobalData.spaces.length == 0) {
          gotoNext("trainer");
        } else if (GlobalData.spaces.length == 1) {
          gotoNext("connect");
        } else {
          gotoNext("select");
        }
      }
    }
  }

  gotoNext(type) {
    setState(() {
      _active = false;
    });
    if (type == "register") {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => RegisterPage(), SharedAxisTransitionType.horizontal));
    } else if (type == "trainer") {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => TrainerPage(false), SharedAxisTransitionType.horizontal));
    } else if (type == "connect") {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => ConnectPage(), SharedAxisTransitionType.horizontal));
    } else if (type == "select") {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => SelectPage(), SharedAxisTransitionType.horizontal));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: render()),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  render() {
    if (_loading) {
      return renderLoading();
    } else {
      return renderForm();
    }
  }

  renderForm() {
    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 90, 20, 30),
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                width: 110,
                height: 110,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(55.0),
                  color: AppColors.PrimaryColor,
                ),
                child: Stack(
                  children: <Widget>[
                    Image.asset("assets/images/common/gradient-green.png",
                        width: 110, height: 110),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: SvgPicture.asset("assets/images/list/user-add.svg",
                          width: 80, height: 80),
                    )
                  ],
                )),
            Text(
              "Create an account",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w300,
                fontSize: 40,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
              width: double.maxFinite,
              child: Text(
                "It's completely free",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Card(
                elevation: 3,
                color: AppColors.boxColor,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Container(
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Sign up with your email",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                            width: MediaQuery.of(context).size.width / 2 - 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.fieldAltColor,
                            ),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _field1,
                              style: TextStyle(color: AppColors.textColor),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Your email address',
                                labelStyle:
                                    TextStyle(color: AppColors.textColor),
                              ),
                            )),
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 30),
                            width: MediaQuery.of(context).size.width / 2 - 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: AppColors.fieldAltColor,
                            ),
                            child: TextField(
                              obscureText: true,
                              controller: _field2,
                              style: TextStyle(color: AppColors.textColor),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Choose a password',
                                labelStyle:
                                    TextStyle(color: AppColors.textColor),
                              ),
                            )),
                        BtnPrimary(
                          label: "CREATE YOUR ACCOUNT",
                          clickFn: _checkRegister,
                        ),
                      ],
                    )),
              ),
            ),

            /*Column (
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container (
                padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                child: InkWell (
                  onTap: () {
                    _loginGoogle();
                  },
                  child: Container (
                    padding: EdgeInsets.only(top: 17),
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: Color(0xFFDB4437),
                    ),
                    child: Text (
                      "CONTINUE WITH GOOGLE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.WhiteColor,
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    )
                  )
                )
              )
            ],
          )*/
          ],
        ));
  }

  renderLoading() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: Text(
        "Creating your account",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.PrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
