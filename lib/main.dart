import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/calendar/session.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/login.dart';
import 'package:ptmate_client/init/register.dart';
import 'package:ptmate_client/init/request.dart';
import 'package:ptmate_client/init/select.dart';
import 'package:ptmate_client/init/setup.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'messaging/chat.dart';

// void main() {
//   tz.initializeTimeZones();
//   runApp(MyApp());
// }

class AppColors {
  // Theme Colors
  static var PrimaryColor = Color(0xFF1CB6C7);
  static const BlueColor = Color(0xFF0C82AC);
  static const GreenColor = Color(0xFF81DB24);
  static const OrangeColor = Color(0xFFF9A117);
  static const OrangeRedColor = Color(0xFFFB691F);
  static const RedColor = Color(0xFFDE1067);
  static const PurpleColor = Color(0xFF8A15E9);
  // Light UI Colors
  static const TextColor = Color(0xFF13131B);
  static const FieldColor = Color(0xFFD3D7D8);
  static const AvatarColor = Color(0xFFBABFC1);
  static const BgColor = Color(0xFFFFFFFF);
  static const BoxColor = Color(0xFFFFFFFF);
  static const WhiteColor = Color(0xFFFFFFFF);
  static const AlertColor = Color(0xFFFB0044);
  static const NavColor = Color(0xFFD3D7D8);
  // Dark UI Colors
  static const TextColorDark = Color(0xFFFFFFFF);
  static const BoxColorDark = Color(0xFF26262D);
  static const FieldColorDark = Color(0xFF26262D);
  static const FieldAltColorDark = Color(0x19FFFFFF);
  static const BgColorDark = Color(0xFF13131B);
  static const NavColorDark = Color(0xFF78787D);
  // Final UI Colors
  static var textColor = TextColor;
  static var boxColor = BoxColor;
  static var fieldColor = FieldColor;
  static var fieldAltColor = FieldColor;
  static var bgColor = BgColor;
  static var navColor = NavColor;
  // Theme Colors
  static var themeDefault = Color(0xFF1CB6C7);
  static var themeBlue = Color(0xFF1DC5C9);
  static var themeDarkblue = Color(0xFF0C82AC);
  static var themeVividblue = Color(0xFF4695ED);
  static var themeGreen = Color(0xFF81DB24);
  static var themeDarkgreen = Color(0xFF53A238);
  static var themeVividgreen = Color(0xFF6CD69D);
  static var themeYellow = Color(0xFFFAB54A);
  static var themeOrange = Color(0xFFFB691F);
  static var themeRed = Color(0xFFDE1053);
  static var themePink = Color(0xFFEB0BD1);
  static var themePurple = Color(0xFF8A15E9);
  static var themeBrown = Color(0xFF8F5D46);
  static var themeRed2 = Color(0xFFF20E0E);
  static var themePink2 = Color(0xFFFFA6F5);
  static var themeLightblue = Color(0xFF52B7FA);
  static var themePurple2 = Color(0xFFAF6CD6);
  static var themeEmeraldgreen = Color(0xFF00A86B);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PT Mate Member',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Quicksand',
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  static _MainPageState appState = _MainPageState();
  @override
  _MainPageState createState() {
    return MainPage.appState = new _MainPageState();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // MUST initialize Firebase here for background isolates
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase once at startup
  await Firebase.initializeApp();

  // Init timezone for scheduled notifications
  tz.initializeTimeZones();

  // Init local notifications
  await NotificationService().init();

  // Register background message handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    'ptmsession',
    'Session Reminders',
    playSound: true,
    priority: Priority.high,
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //const NotificationDetails platformChannelSpecifics = NotificationDetails(android: _androidNotificationDetails);

  Future<void> showNotifications() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Title',
      'This is the Notification Body',
      //platformChannelSpecifics,
      NotificationDetails(
          android: AndroidNotificationDetails(
        'ptmsession',
        'Session Reminders',
        playSound: true,
        priority: Priority.high,
        importance: Importance.max,
      )),
      payload: 'Notification Payload',
    );
  }

  Future<void> scheduleNotifications(title, body, time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        //tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
        tz.TZDateTime.from(time, tz.local),
        NotificationDetails(
            android: AndroidNotificationDetails(
          'ptmsession',
          'Session Reminders',
          playSound: true,
          priority: Priority.high,
          importance: Importance.high,
        )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime
        // androidAllowWhileIdle: true,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime
        );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings(
            '@drawable/ic_stat_onesignal_default');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      // onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    // 🔑 ANDROID 13+ RUNTIME PERMISSION
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Ask for general notification permission
    await androidPlugin?.requestNotificationsPermission();

    // If you rely on exact scheduled notifications like you do:
    await androidPlugin?.requestExactAlarmsPermission();
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}
}

void _onNotificationTap(NotificationResponse response) {
  final payloadString = response.payload;
  if (payloadString == null || payloadString.isEmpty) return;

  late final Map<String, dynamic> payload;

  try {
    payload = jsonDecode(payloadString);
  } catch (_) {
    return;
  }

  _handleNotificationNavigation(
    type: payload["type"] ?? "",
    space: payload["space"] ?? "",
    id: payload["id"] ?? "",
  );
}

void _handleNotificationNavigation({
  required String type,
  required String space,
  required String id,
}) {
  if (type.isEmpty) return;

  // CHAT
  if (type == "chat" && space == GlobalData.space.id) {
    if (id == GlobalData.chat.id) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(GlobalData.chat.id, GlobalData.chat, "pt"),
        ),
      );
    } else {
      for (var item in GlobalData.chats) {
        if (item.id == id) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ChatPage(item.id, item, "group"),
            ),
          );
          return;
        }
      }

      for (var item in GlobalData.chatsStaff) {
        if (item.id == id) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ChatPage(item.id, item, "staff"),
            ),
          );
          return;
        }
      }
    }
  }

  // SESSION
  else if (type == "session" && space == GlobalData.space.id) {
    for (var item in GlobalData.sessions) {
      if (item.id == id) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => item.attendance == 3
                ? ResultsPage(item.id, item)
                : SessionPage(item.id, item),
          ),
        );
        return;
      }
    }
  }
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  var _ctrlIn1;
  var _ctrlIn2;
  var _aniIn1;
  var _aniIn2;
  double _opacity = 0;
  int _speed = 300;
  int _spaces = 0;
  int _counter = 0;
  bool _active = true;
  bool _logChecked = false;
  Color bg = AppColors.BgColor;
  //FirebaseMessaging _messaging = FirebaseMessaging();

  Future<void> registerNotification() async {
    final FirebaseMessaging _messaging = FirebaseMessaging.instance;

    // Request permission (Android 13+ and iOS)
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      // User blocked notifications -> nothing will show
      return;
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("Foreground RemoteMessage: ${message.messageId}");

      final RemoteNotification? notification = message.notification;

      if (!Platform.isIOS && notification != null) {
        NotificationService().flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'ptmsession',
                  'Session Reminders',
                  playSound: true,
                  priority: Priority.high,
                  importance: Importance.max,
                ),
              ),
              payload: jsonEncode(message.data),
            );
      }
    });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   final title = message.notification?.title;
    //   final body = message.notification?.body;
    //   final data = message.data;
    //   final type = data["type"];
    //   print("====data==$data");
    // });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      print("====FCM data==$data");
      _handleNotificationNavigation(
        type: data["type"] ?? "",
        space: data["space"] ?? "",
        id: data["id"] ?? "",
      );
    });

    // FCM token
    try {
      final token = await _messaging.getToken();
      GlobalUser.token = token ?? "";
      debugPrint("GlobalUser.token :: ${GlobalUser.token}");
      FirebaseSender.updateToken(GlobalUser.uid, token);
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }

  setNotification(title, body, date) {
    NotificationService._notificationService
        .scheduleNotifications(title, body, date);
  }

  delNotifications() {
    NotificationService._notificationService.cancelAllNotifications();
  }

  Future<void> checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        initialMessage.notification?.title ?? "",
        initialMessage.notification?.body ?? "",
      );
      if (initialMessage.notification != null) {
        GlobalUI.notification[0] = initialMessage.data["type"] ?? "";
        GlobalUI.notification[1] = initialMessage.data["space"] ?? "";
        GlobalUI.notification[2] = initialMessage.data["id"] ?? "";
      }
    }
  }

  updateData() {
    if (this.mounted && _active) {
      if (GlobalUser.phone == "") {
        GlobalUser.email = FirebaseAuth.instance.currentUser!.email!;
        if (GlobalUser.name == "incomplete") {
          _gotoSetup();
        } else {
          _gotoRegister();
        }
      } else {
        setState(() {
          _spaces = GlobalUser.spaces;
        });
        if (_spaces == 0) {
          _gotoTrainer();
        }
        //Connector.getLog();
        updateLog();
      }
    }
  }

  updateLog() {
    var found = false;
    var id = "";
    var client = "";
    if (this.mounted && _active) {
      for (var item in GlobalData.logs) {
        if (item.type == "trainerrequest") {
          found = true;
          client = item.message;
          id = item.id;
        }
      }
      if (!found) {
        setState(() {
          _logChecked = true;
        });
        updateSpaces();
      } else {
        _gotoRequest(id, client);
      }
    }
  }

  updateSpaces() {
    if (this.mounted && _active) {
      setState(() {
        _counter += 1;
      });
      if (_counter >= GlobalUser.spaces && _logChecked) {
        if (GlobalData.spaces.length == 0) {
          _gotoTrainer();
        } else if (GlobalData.spaces.length == 1) {
          _gotoConnect();
        } else {
          _gotoSelect();
        }
      }
    }
  }

  _gotoRequest(id, client) {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(() => RequestPage(id, client),
              SharedAxisTransitionType.horizontal));
    });
  }

  _gotoLogin() {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => LoginPage(), SharedAxisTransitionType.horizontal));
    });
  }

  _gotoRegister() {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => RegisterPage(), SharedAxisTransitionType.horizontal));
    });
  }

  _gotoSetup() {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => SetupPage(), SharedAxisTransitionType.horizontal));
    });
  }

  _gotoTrainer() {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => TrainerPage(false), SharedAxisTransitionType.horizontal));
    });
  }

  _gotoSelect() {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => SelectPage(), SharedAxisTransitionType.horizontal));
    });
  }

  _gotoConnect() {
    Future.delayed(const Duration(milliseconds: 800), () {
      _ctrlIn1.reverse();
      _ctrlIn2.reverse();
      setState(() {
        _opacity = 0;
        _active = false;
      });
    });
    GlobalData.space = GlobalData.spaces[0];
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => ConnectPage(), SharedAxisTransitionType.horizontal));
    });
  }

  @override
  void initState() {
    super.initState();

    _checkUserLogged();
    checkForInitialMessage();

    _ctrlIn1 = AnimationController(
        vsync: this, duration: Duration(milliseconds: _speed));
    _aniIn1 = Tween(begin: 0.2, end: 1.05).animate(CurvedAnimation(
      parent: _ctrlIn1,
      curve: Curves.easeOut,
    ));
    _ctrlIn2 = AnimationController(
        vsync: this, duration: Duration(milliseconds: _speed));
    _aniIn2 = Tween(begin: 0.5, end: 0.9).animate(CurvedAnimation(
      parent: _ctrlIn1,
      curve: Curves.easeOut,
    ));

    _ctrlIn1.addListener(() {
      setState(() {
        _opacity = _ctrlIn1.value;
      });
    });

    _ctrlIn1.forward(from: 0.0);
    _ctrlIn2.forward(from: 0.0);
    setState(() {
      _opacity = 1;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Firebase.initializeApp().whenComplete(() {
  //     NotificationService().init();
  //     _checkUserLogged();
  //     setState(() {});
  //   });

  //   checkForInitialMessage();

  //   _ctrlIn1 = AnimationController(
  //       vsync: this, duration: Duration(milliseconds: _speed));
  //   _aniIn1 = Tween(begin: 0.2, end: 1.05).animate(CurvedAnimation(
  //     parent: _ctrlIn1,
  //     curve: Curves.easeOut,
  //   ));
  //   _ctrlIn2 = AnimationController(
  //       vsync: this, duration: Duration(milliseconds: _speed));
  //   _aniIn2 = Tween(begin: 0.5, end: 0.9).animate(CurvedAnimation(
  //     parent: _ctrlIn1,
  //     curve: Curves.easeOut,
  //   ));
  //   _ctrlIn1.addListener(() {
  //     setState(() {
  //       _opacity = _ctrlIn1.value;
  //     });
  //   });

  //   _ctrlIn1.forward(from: 0.0);
  //   _ctrlIn2.forward(from: 0.0);
  //   setState(() {
  //     _opacity = 1;
  //   });
  // }

  _checkUserLogged() {
    //FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser != null) {
      _continueLogged();
    } else {
      _gotoLogin();
    }
  }

  _continueLogged() async {
    /*await FirebaseAuth.instance.signOut().then((value) => 
      //Navigator.push(context, PageRoutes.sharedAxis(()=>Nav(), SharedAxisTransitionType.horizontal));
      print("logged out")
    );*/
    if (FirebaseAuth.instance.currentUser != null) {
      GlobalUser.uid = FirebaseAuth.instance.currentUser!.uid;
      GlobalUser.email = FirebaseAuth.instance.currentUser!.email!;

      print("=======${GlobalUser.uid}========");
      // if (kDebugMode) {
      // GlobalUser.uid = '72ZKHrNiY4VMuhJoqI0L2ie4Wu83';
      // GlobalUser.uid = 'VqyszJ62pxbJNPuMtY1zp72Qpgv2'; // Peetie
      //GlobalUser.uid = 'oqTb4iFZGZgBy9eFIf8eppDsVDg2'; // Peetie 2
      // GlobalUser.uid = '10A6N2LTO7cEfcsTRVO5pe48fDQ2'; // Kirsten
      // GlobalUser.uid = '2SHH3S4lFbRf9VHtJPmztXFlYXo2'; // Kirsten
      // GlobalUser.uid = '9NxvVP2vI3THkWpwzR5N6hhYCp62'; // Cam
      // }
      NotificationService._notificationService.cancelAllNotifications();
      registerNotification();

      Connector.getUser();
    }
  }

  @override
  void dispose() {
    _ctrlIn1.dispose();
    _ctrlIn2.dispose();
    super.dispose();
  }

  updateColors() {
    AppColors.textColor = AppColors.TextColorDark;
    AppColors.boxColor = AppColors.BoxColorDark;
    AppColors.fieldColor = AppColors.FieldColorDark;
    AppColors.fieldAltColor = AppColors.FieldAltColorDark;
    AppColors.bgColor = AppColors.BgColorDark;
    AppColors.navColor = AppColors.NavColorDark;
    GlobalUI.dark = true;
  }

  @override
  Widget build(BuildContext context) {
    var qdarkMode = MediaQuery.of(context).platformBrightness;
    if (qdarkMode == Brightness.dark) {
      updateColors();
    }
    return Scaffold(
        body: Container(
      color: AppColors.bgColor,
      child: Stack(
        children: [
          Positioned(
              top: MediaQuery.of(context).size.height / 2 - 140,
              left: MediaQuery.of(context).size.width / 2 - 140,
              child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Transform.scale(
                    scale: _aniIn1.value,
                    child: Image.asset(
                        "assets/images/common/gradient-blur-blue.png",
                        width: 280,
                        height: 280),
                  ))),
          Positioned(
              top: MediaQuery.of(context).size.height / 2 - 60,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Transform.scale(
                    scale: _aniIn2.value,
                    child: SvgPicture.asset("assets/images/common/logo.svg",
                        width: 120, height: 120),
                  )))
        ],
      ),
    ));
  }
}
