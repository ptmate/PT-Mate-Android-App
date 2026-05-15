import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/init/success.dart';
import 'package:animations/animations.dart';


class ScannerPage extends StatefulWidget {
  static _ScannerPageState appState = _ScannerPageState();
  const ScannerPage();
  @override
  _ScannerPageState createState() {
    return ScannerPage.appState = new _ScannerPageState();
  }
}


class _ScannerPageState extends State<ScannerPage> {


  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var clients;
  var token;
  ModelSpace item = ModelSpace("", "", "", "", "", "", "", "", "", "", ["","","","",""], [], [], false, false, true, false, "", "", 0, 0, false, false, "default", "", [], false, "", 24, "", [], false, false, "au", false, "", false, true, false, "", "", false, true, "", 0, 0, false, [], []);


  @override
  void initState() {
    super.initState();
    setState(() {
      clients = [];
    });
  }


  @override
  void reassemble() {
    super.reassemble();
    //controller!.pauseCamera();
    //controller!.resumeCamera();
  }


  updateData() {
    if (this.mounted) {
      setState(() {
        clients = GlobalData.trainerClients;
        token = GlobalUI.spaceToken;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("Connect space"),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
              child: Text(
                "Scan their business QR code",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Container(height: 20),
            Expanded(flex: 4, child: _buildQrView(context)),
          ]
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      var found = false;
      if(scanData.code != null) {
        var arr = scanData.code!.split("/");
        var code = "";
        var name = "";
        if(arr.length > 1) {
          code = arr[arr.length-2];
        }
        for(var space in GlobalData.allspaces) {
          if(space.id == code) {
            found = true;
            item = space;
            name = space.business;
          }
        }
        if(found) {
          Connector.getAllClients(code);
          Connector.getTrainerToken(code);
          showAlertConnect(scanData.code, name);
        } else {
          showAlertError();
        }
        setState(() {
          result = scanData;
        });
      }
      
    });
  }


  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    //log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }


  showAlertConnect(id, name) {
    controller!.pauseCamera();
    
    AlertDialog alert = AlertDialog(
      title: Text("Connect to space"),
      content: Text("Do you want to connect to "+name+"?"),
      actions: [
        TextButton(
          child: Text("Connect"),
          onPressed: () {
            connectSpace();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
            controller!.resumeCamera();
          },
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


  connectSpace() {
    var client = "";
    for(var citem in clients) {
      if(citem.name == GlobalUser.email || citem.image == GlobalUser.phone || citem.token == GlobalUser.name) {
        client = citem.id;
      }
    }
    GlobalData.spaces.add(item);
    GlobalData.space = item;
    var type = "";
    GlobalUI.isSignup = true;
    if(item.id != "" && item != null) {
      FirebaseSender.connectSpace(item, item.id, client, GlobalUser.ecName, GlobalUser.ecPhone, GlobalUser.ecType);
      if(GlobalData.space.showForms && GlobalData.space.pre != "") {
        Connector.getForms();
        type = "form";
      }
      Navigator.push(context, PageRoutes.sharedAxis(()=>SuccessPage(type), SharedAxisTransitionType.horizontal));
    }
  }


  showAlertError() {
    controller!.pauseCamera();
    AlertDialog alert = AlertDialog(
      title: Text("Space not found"),
      content: Text("There is no training space associated with this QR code."),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            controller!.resumeCamera();
            Navigator.of(context).pop();
          },
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


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


}