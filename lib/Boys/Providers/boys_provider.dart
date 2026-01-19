import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/my_functions.dart';
import '../Screens/pending_admin_approval.dart';

class BoysProvider extends ChangeNotifier{

  final FirebaseFirestore db = FirebaseFirestore.instance;


  TextEditingController boyNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController guardianController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }
  String? selectedBloodGroup;
  DateTime? dobDateTime;

  void changeBloodGroup(String value) {
    selectedBloodGroup = value;
    notifyListeners();
  }

  Future<void> selectDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobDateTime = picked;
      dobController.text =
      "${picked.day}/${picked.month}/${picked.year}";
      notifyListeners();
    }
  }


  Future<void> registerNewBoyFun(BuildContext context, String from) async {
    try {
      // 🔒 DOB validation
      if (dobDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select date of birth")),
        );
        return;
      }

      final phone = phoneController.text.trim();

      // 🔒 Phone validation
      if (phone.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter valid 10 digit phone number")),
        );
        return;
      }

      /// 🔍 STEP 1: CHECK PHONE ALREADY EXISTS
      final phoneCheck = await db
          .collection("BOYS")
          .where("PHONE", isEqualTo: phone)
          .limit(1)
          .get();

      if (phoneCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This phone number is already registered"),
          ),
        );
        return;
      }

      /// ✅ STEP 2: REGISTER BOY
      final boyId = "BOY${DateTime.now().millisecondsSinceEpoch}";

      Map<String, dynamic> map = {
        "BOY_ID": boyId,
        "NAME": boyNameController.text.trim(),
        "NAME_SEARCH": boyNameController.text.trim().toLowerCase(),
        "PHONE": phone,
        "GUARDIAN_PHONE": guardianController.text.trim(),
        "DOB": dobController.text.trim(),
        "DOB_TS": Timestamp.fromDate(dobDateTime!),
        "BLOOD_GROUP": selectedBloodGroup,
        "PLACE": placeController.text.trim(),
        "DISTRICT": districtController.text.trim(),
        "PIN_CODE": pinController.text.trim(),
        "ADDRESS": addressController.text.trim(),
        "PASSWORD": confirmPasswordController.text.trim(),
        "CREATED_TIME": FieldValue.serverTimestamp(),
      };

      if (from == 'MANAGER') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? adminName = prefs.getString('adminName');
        String? adminID = prefs.getString('adminID');

        map.addAll({
          "STATUS": "APPROVED",
          "DIRECT_APPROVAL_STATUS": "YES",
          "APPROVED_BY": adminName,
          "APPROVED_BY_ID": adminID,
          "APPROVED_TIME": FieldValue.serverTimestamp(),
        });
      } else {
        map.addAll({
          "STATUS": "PENDING",
          "DIRECT_APPROVAL_STATUS": "NO",
        });
      }
      await db.collection("BOYS").doc(boyId).set(map);
      Navigator.pop(context);

      if(from=='MANAGER'){
        fetchBoys(); // refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Boy registered successfully")),
          ),
        );
      }else{
        callNextReplacement(PendingAdminApproval(), context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Registered successfully,Pending Admin Approval")),
          ),
        );
      }
    } catch (e) {
      debugPrint("Register Boy Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to register boy")),
      );
    }
  }

  List<Map<String, dynamic>> boysList = [];
  List<Map<String, dynamic>> filterBoysList = [];
  List<Map<String, dynamic>> initialBoysList = []; // first 50

  bool isLoadingBoys = false;
  Future<void> fetchBoys() async {
    try {
      isLoadingBoys = true;
      notifyListeners();

      final snapshot = await db
          .collection("BOYS")
          .orderBy("CREATED_TIME", descending: true)
          .limit(100)
          .get();

      initialBoysList =
          snapshot.docs.map((e) => e.data()).toList();

      filterBoysList = List.from(initialBoysList);

    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      isLoadingBoys = false;
      notifyListeners();
    }
  }


  void filterBoys(String query) {
    if (query.isEmpty) {
      filterBoysList = List.from(boysList);
    } else {
      filterBoysList = boysList.where((boy) {
        final name = (boy['NAME'] ?? '').toLowerCase();
        final phone = (boy['PHONE'] ?? '');
        return name.contains(query.toLowerCase()) ||
            phone.contains(query);
      }).toList();
    }
    notifyListeners();
  }
  bool isSearching = false;
  Timer? _debounce;
  DocumentSnapshot? lastSearchDoc;
  void searchBoys(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchFromDb(query);
    });
  }

  Future<void> _searchFromDb(String query) async {

    // 🔁 RESET STATE WHEN EMPTY
    if (query.trim().isEmpty) {
      filterBoysList = List.from(initialBoysList);
      notifyListeners();
      return;
    }

    try {
      isSearching = true;
      notifyListeners();

      final q = query.toLowerCase();

      final snap = await db
          .collection("BOYS")
          .orderBy("NAME_SEARCH")
          .startAt([q])
          .endAt([q + '\uf8ff'])
          .limit(20)
          .get();

      filterBoysList =
          snap.docs.map((e) => e.data() as Map<String, dynamic>).toList();

    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clearBoyForm() {
    boyNameController.clear();
    phoneController.clear();
    guardianController.clear();
    dobController.clear();
    placeController.clear();
    districtController.clear();
    pinController.clear();
    addressController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    selectedBloodGroup = null;
    dobDateTime = null;

    notifyListeners();
  }




}