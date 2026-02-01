
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Boys/Providers/boys_provider.dart';
import '../../Boys/Screens/navbar/boy_bottomNav.dart';
import '../../Boys/Screens/home/boy_home.dart';
import '../../Boys/Screens/pending_admin_approval.dart';
import '../../Constants/my_functions.dart';
import '../Screens/manager_bottom.dart';
import 'ManagerProvider.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginProvider extends ChangeNotifier{

  final FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController loginphoneController = TextEditingController();


  LoginProvider(){
    getPackageName();
  }

  Future<void> getPackageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo.packageName;
    // print("${packageName}packagenameee");
    notifyListeners();
  }


  bool otpLoader = false;
  String? packageName;
  Future<void> userAuthorized({
    required String phone,
    required String password,
    required BuildContext context,
  }) async {

    // 1. Start Loading
    otpLoader = true;
    notifyListeners();
    try {
      if(packageName=='com.evento.manager') {
        QuerySnapshot query = await db
            .collection("ADMINS")
            .where("PHONE_NUMBER", isEqualTo: phone)
            .where("PASSWORD", isEqualTo: password)
            .where("TYPE", isEqualTo: "MANAGER")
            .get();

        if (query.docs.isNotEmpty) {
          Map<dynamic, dynamic> dataMap = query.docs.first.data() as Map;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String adminID = query.docs.first.id;
          String adminName = dataMap['NAME'] ?? "";
          await prefs.setString('phone_number', phone);
          await prefs.setString('password', password);
          await prefs.setString('adminName', adminName);
          await prefs.setString('adminID', adminID);


          final managerProvider =
          Provider.of<ManagerProvider>(context, listen: false);
          managerProvider.setTabIndex(0);
          managerProvider.fetchRunningEvents();

          callNextReplacement(ManagerBottom(
            adminID: adminID, adminName: adminName, adminPhone: phone,isLockBool: false,),
              context);
        } else {
          // 4. Failure: No match found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Credentials or you are not a Manager"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      else{
        print('$phone OIJDOEIJFR $password');

        QuerySnapshot query = await db
            .collection("BOYS")
            .where("PHONE", isEqualTo: phone)
            .where("PASSWORD", isEqualTo: password)
            .get();

        if (query.docs.isNotEmpty) {
          Map<dynamic, dynamic> dataMap = query.docs.first.data() as Map;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String adminID = query.docs.first.id;
          String adminName = dataMap['NAME'] ?? "";
          await prefs.setString('phone_number', phone);
          await prefs.setString('password', password);

          await prefs.setString('adminName', adminName);
          await prefs.setString('adminID', adminID);

          await prefs.setString('boyName', adminName);
          await prefs.setString('boyID', adminID);
          await prefs.setString('boyPhone', phone);

          print('$phone NFRJFERF $adminID');

          final boysProvder =
          Provider.of<BoysProvider>(context, listen: false);

          if(dataMap['STATUS']=='APPROVED'){
            callNextReplacement(BoyBottomNavBar(boyID: adminID, boyName: adminName, boyPhone: phone,isLockBool: false,), context);

          }else{
            callNextReplacement(PendingAdminApproval(), context);

          }

        } else {
          // 4. Failure: No match found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Credentials or you are not a Manager"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      // 5. Stop Loading
      otpLoader = false;
      notifyListeners();
    }
  }
}