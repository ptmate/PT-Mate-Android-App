import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/password.dart';
import 'package:ptmate_client/init/register.dart';
import 'package:ptmate_client/init/select.dart';
import 'package:ptmate_client/init/setup.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:ptmate_client/main.dart';

class LoginLoginPage extends StatefulWidget {
  static _LoginLoginPageState appState = _LoginLoginPageState();
  //_LoginLoginPageState createState() => _LoginLoginPageState();
  _LoginLoginPageState createState() {
    return LoginLoginPage.appState = new _LoginLoginPageState();
  }
}

class _LoginLoginPageState extends State<LoginLoginPage>
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
    if (!mounted) return;
    setState(() {
      _active = true;
    });
  }

  @override
  void dispose() {
    // if (!mounted) return;
    // setState(() {
    _active = false;
    // });
    super.dispose();
  }

  _checkLogin() {
    if (_field1.text != "" && _field2.text != "") {
      if (!mounted) return;
      setState(() {
        _loading = true;
      });
      _loginUser();
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

  _loginUser() async {
    try {
      //var userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _field1.text, password: _field2.text)
          .then((value) async {
        GlobalUser.uid = FirebaseAuth.instance.currentUser!.uid;
        GlobalUser.email = FirebaseAuth.instance.currentUser!.email!;

        // Cancel any old scheduled notifications (from another user / previous sessions)
        await NotificationService().cancelAllNotifications();

        // Register FCM + local notifications + save token to backend
        // using your MainPage state method
        await MainPage.appState.registerNotification();
        //checkTrainer()
        Connector.checkTrainer(FirebaseAuth.instance.currentUser!.uid);
        // User? user = FirebaseAuth.instance.currentUser;

        // if (user == null) return null;

        // // false → returns cached token
        // // true → forces refresh from Firebase server
        // String? token = await user.getIdToken(true);
        // print("token ::  ${token}");
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showError('Wrong password provided for that user.');
      } else {
        showError(e.message);
      }
    }
  }

  _loginGoogle() {
    signInWithGoogle().then((result) {
      //if (result != null) {
      if (result != "") {
        //checkTrainer();
        //Connector.checkTrainer();
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

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser!;
    assert(user.uid == currentUser.uid);
    GlobalUser.uid = currentUser.uid;
    GlobalUser.email = currentUser.email!;

    print('signInWithGoogle succeeded: $user');
    Connector.checkTrainer(GlobalUser.uid);

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
      title: Text("Error logging in"),
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
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  checkTrainer(exists) {
    //if(FirebaseAuth.instance.currentUser!.displayName == "client" || FirebaseAuth.instance.currentUser!.displayName == "") {
    if (!exists) {
      GlobalUser.uid = FirebaseAuth.instance.currentUser!.uid;
      GlobalUser.email = FirebaseAuth.instance.currentUser!.email!;
      Connector.getUser();
    } else {
      if (FirebaseAuth.instance.currentUser!.displayName == "client" ||
          FirebaseAuth.instance.currentUser!.displayName == "Client") {
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
      }
    }
  }

  updateData() {
    if (this.mounted && _active) {
      if (GlobalUser.phone == "") {
        //print("user doesn't exist");
        //gotoNext("register");
        if (GlobalUser.name == "incomplete") {
          gotoNext("setup");
        } else {
          showNotExistAlert();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _spaces = GlobalUser.spaces;
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
  }

  showNotExistAlert() {
    /*Widget okButton = TextButton(
      child: Text("Log in using email & password"),
      onPressed: () {
        setState(() {
          _loading = false;
        });
        Navigator.of(context).pop();
        FirebaseAuth.instance.currentUser!.delete();
        FirebaseAuth.instance.signOut();
      },
    );
    Widget okButton2 = TextButton(
      child: Text("Set up a new account"),
      onPressed: () {
        gotoNext("register");
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("PT Mate account not found"),
      content: Text("Looks like there's no PT Mate user associated with your Google Account. If you already have an account, you might have used a different sign up method. What do you want to do?"),
      actions: [
        okButton,
        okButton2
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );*/
    gotoNext("register");
  }

  updateSpaces() {
    if (this.mounted && _active) {
      if (!mounted) return;
      setState(() {
        _counter += 1;
      });
      if (_counter == GlobalUser.spaces) {
        if (GlobalData.spaces.length == 0) {
          gotoNext("trainer");
        } else if (GlobalData.spaces.length == 1) {
          GlobalData.space = GlobalData.spaces[0];
          gotoNext("connect");
        } else {
          gotoNext("select");
        }
      }
    }
  }

  gotoNext(type) {
    if (!mounted) return;
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
    } else if (type == "setup") {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => SetupPage(), SharedAxisTransitionType.horizontal));
    }
  }

  _gotoReset() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordPage()),
    );
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
                    Image.asset("assets/images/common/gradient.png",
                        width: 110, height: 110),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: SvgPicture.asset("assets/images/list/user.svg",
                          width: 80, height: 80),
                    )
                  ],
                )),
            Text(
              "Login",
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
                "to your existing account",
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
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Login with your email",
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
                                labelText: 'Your password',
                                labelStyle:
                                    TextStyle(color: AppColors.textColor),
                              ),
                            )),
                        BtnPrimary(
                          label: "LOG IN",
                          clickFn: _checkLogin,
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: BtnTertiary(
                              label: "FORGOT YOUR PASSWORD?",
                              clickFn: _gotoReset,
                            ))
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
        "Logging you in",
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
