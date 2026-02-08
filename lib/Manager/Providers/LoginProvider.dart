
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Boys/Providers/boys_provider.dart';
import '../../Boys/Screens/Block/block_boy.dart';
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
      else {
        print('$phone LOGIN CHECK $password');

        QuerySnapshot query = await db
            .collection("BOYS")
            .where("PHONE", isEqualTo: phone)
            .where("PASSWORD", isEqualTo: password)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          Map<dynamic, dynamic> dataMap = query.docs.first.data() as Map;
          SharedPreferences prefs = await SharedPreferences.getInstance();

          String boyID = query.docs.first.id;
          String boyName = dataMap['NAME'] ?? "";
          final String boyPhotoUrl =
          dataMap['BOY_PHOTO_URL'] is String
              ? dataMap['BOY_PHOTO_URL'] as String
              : "";



          // 🔥 Save Local Login Data
          await prefs.setString('phone_number', phone);
          await prefs.setString('password', password);
          await prefs.setString('boyName', boyName);
          await prefs.setString('boyID', boyID);
          await prefs.setString('boyPhone', phone);
          await prefs.setString('boyPhotoUrl', boyPhotoUrl);

          // also set as admin (you already used)
          await prefs.setString('adminName', boyName);
          await prefs.setString('adminID', boyID);

          print('$phone LOGIN SUCCESS → $boyID');

          final boysProvider = Provider.of<BoysProvider>(context, listen: false);

          // 🚫 1. BLOCKED CHECK
          if (dataMap['BLOCK_STATUS'] == "BLOCKED") {
            callNextReplacement(const BoyBlockedScreen(), context);
            return;
          }

          // ✅ 2. APPROVED CHECK
          if (dataMap['STATUS'] == "APPROVED") {
            callNextReplacement(
              BoyBottomNavBar(
                boyID: boyID,
                boyName: boyName,
                boyPhone: phone,
                isLockBool: false, boyPhoto: boyPhotoUrl,
              ),
              context,
            );
          }
          // 🕒 3. PENDING APPROVAL
          else {
            callNextReplacement(PendingAdminApproval(), context);
          }

        }
        // ❌ INVALID CREDENTIALS
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Credentials"),
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