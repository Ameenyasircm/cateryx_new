import 'dart:async';
import 'dart:io';

import 'package:cateryyx/Boys/Screens/home/boy_home.dart';
import 'package:cateryyx/Manager/Screens/splashScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Constants/my_functions.dart';
import '../../Manager/Providers/EventDetailProvider.dart';
import '../../Manager/Providers/LoginProvider.dart';
import '../../Manager/Providers/ManagerProvider.dart';
import '../../Manager/Screens/manager_bottom.dart';
import '../../core/utils/alert_utils.dart';
import '../Screens/navbar/boy_bottomNav.dart';
import '../Screens/pending_admin_approval.dart';

class BoysProvider extends ChangeNotifier{

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final DatabaseReference mRoot = FirebaseDatabase.instance.ref();

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
  TextEditingController wageController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  File? aadhaarPhoto;
  final ImagePicker _imagePicker = ImagePicker();

  BoysProvider(){
    getAppVersion();
    LockAppCheckFisrt();
  }

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

  Future<void> pickAadhaarPhoto(BuildContext context) async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          aadhaarPhoto = File(pickedFile.path);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to pick image")),
        );
      }
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

      /// 👉 Prepare name and keywords
      final String name = boyNameController.text.trim();

      // --------------------
      // 🔥 Generate Search Keywords
      // --------------------

      /// 1. Full name prefixes
      List<String> nameKeywords = generateKeywords(name);

      /// 2. Each word prefixes
      if (name.contains(" ")) {
        name.split(" ").forEach((word) {
          nameKeywords.addAll(generateKeywords(word));
        });
      }

      /// 3. Phone prefixes
      List<String> phoneKeywords = generateKeywords(phone);

      /// 4. Merge (remove duplicates)
      List<String> finalKeywords = {
        ...nameKeywords,
        ...phoneKeywords,
      }.toList();

      /// ✅ STEP 2: REGISTER BOY
      final boyId = "BOY${DateTime.now().millisecondsSinceEpoch}";

      /// ✅ STEP 3: UPLOAD AADHAAR PHOTO (if provided)
      String? aadhaarPhotoUrl;
      if (aadhaarPhoto != null) {
        try {
          final supabase = Supabase.instance.client;
          final filePath = '$boyId.jpg';
          
          // Upload to Supabase Storage (pass File directly)
          await supabase.storage
              .from('boys_aadhaar')
              .upload(filePath, aadhaarPhoto!, fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ));
          
          // Get public URL
          final publicUrl = supabase.storage
              .from('boys_aadhaar')
              .getPublicUrl(filePath);
          
          aadhaarPhotoUrl = publicUrl;
        } catch (e) {
          debugPrint("Error uploading Aadhaar photo: $e");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to upload Aadhaar photo: ${e.toString()}")),
            );
          }
          return;
        }
      }

      Map<String, dynamic> map = {
        "BOY_ID": boyId,
        "NAME": name,
        "NAME_SEARCH": name.toLowerCase(),
        "PHONE": phone,
        "GUARDIAN_PHONE": guardianController.text.trim(),
        "DOB": dobController.text.trim(),
        "DOB_TS": Timestamp.fromDate(dobDateTime!),
        // "BLOOD_GROUP": selectedBloodGroup,
        "PLACE": placeController.text.trim(),
        "DISTRICT": districtController.text.trim(),
        "PIN_CODE": pinController.text.trim(),
        "ADDRESS": addressController.text.trim(),
        "PASSWORD": confirmPasswordController.text.trim(),
        "CREATED_TIME": FieldValue.serverTimestamp(),

        // 🔥 Add final merged keywords
        "SEARCH_KEYWORDS": finalKeywords,
      };

      // Add Aadhaar photo URL if uploaded
      if (aadhaarPhotoUrl != null) {
        map["AADHAAR_PHOTO_URL"] = aadhaarPhotoUrl;
      }

      // -------------------------------------------------------
      // 🔥 ADD WAGE (Manager gives real wage, others = 0)
      // -------------------------------------------------------
      if (from == "MANAGER") {
        final wage = wageController.text.trim().isEmpty
            ? 0
            : double.tryParse(wageController.text.trim()) ?? 0;

        map["WAGE"] = wage;
      } else {
        map["WAGE"] = 0;
      }

      // -------------------------------------------------------
      // 🔥 APPROVAL LOGIC
      // -------------------------------------------------------
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

      // -------------------------------------------------------
      // 🔥 SAVE TO FIRESTORE
      // -------------------------------------------------------
      await db.collection("BOYS").doc(boyId).set(map);
      Navigator.pop(context);

      if (from == 'MANAGER') {
        fetchBoys(); // refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Boy registered successfully")),
          ),
        );
      } else {
        callNextReplacement(PendingAdminApproval(), context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text("Registered successfully, Pending Admin Approval"),
            ),
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

  List<String> generateKeywords(String text) {
    text = text.toLowerCase().trim();
    List<String> keywords = [];

    for (int i = 1; i <= text.length; i++) {
      keywords.add(text.substring(0, i));
    }

    return keywords;
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
    wageController.clear();
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
    aadhaarPhoto = null;

    notifyListeners();
  }


  /// App Lock Code

  String? appVersion;
  String currentVersion='';
  String buildNumber="";

  Future<void> getAppVersion() async {
    PackageInfo.fromPlatform().then((value) {
      currentVersion=value.version;
      buildNumber = value.buildNumber;
      appVersion=buildNumber;
      notifyListeners();
    });

  }

  String? packageName;
  Future<void> LockAppCheckFisrt() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo.packageName;
    if(packageName=='com.evento.boys'){
      lockAppBoys();
    }else {
      lockAppGM();
    }
    notifyListeners();
  }

  void lockAppBoys() {
    print("boyysssss login  here");
    mRoot.child("0").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        List<String> versions = Platform.isIOS
            ? map['iOSVersion'].toString().split(',')
            : map['BoysAppVersion'].toString().split(',');

        print("Boys App Lock "+versions.toString() + ' ' + appVersion.toString());

        if (!versions.contains(appVersion)) {
          // bool versionStatus = await checkVersionExist();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? name = prefs.getString('adminName');
          String? id = prefs.getString('adminName');
          String? phone = prefs.getString('adminName');

            String address = map[Platform.isIOS ? "ADDRESS_iOS" : 'ADDRESS'].toString();
            String button = map['BUTTON'].toString();
            String text = map['TEXT'].toString();
            // showGlobalUpdateAlert(text);

          print(' need to lock boy appp ');
            runApp(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_) => LoginProvider()),
                  ChangeNotifierProvider(create: (_) => ManagerProvider()),
                  ChangeNotifierProvider(create: (_) => BoysProvider()),
                  ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
                ],
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    useMaterial3: true,
                    primarySwatch: Colors.blue,
                  ),
                  home: BoyBottomNavBar(boyID: id!,boyPhone: phone!,boyName:name!,isLockBool: true,),
                ),
              ),
            );
        }
      }
    });
  }

  void ReOpen(BuildContext context) {
    print("boyysssss login  here");
    mRoot.child("0").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        List<String> versions = Platform.isIOS
            ? map['iOSVersion'].toString().split(',')
            : map['BoysAppVersion'].toString().split(',');

        print("Boys App Lock "+versions.toString() + ' ' + appVersion.toString());

        if (!versions.contains(appVersion)) {
          // bool versionStatus = await checkVersionExist();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? name = prefs.getString('adminName');
          String? id = prefs.getString('adminName');
          String? phone = prefs.getString('adminName');

          String address = map[Platform.isIOS ? "ADDRESS_iOS" : 'ADDRESS'].toString();
          String button = map['BUTTON'].toString();
          String text = map['TEXT'].toString();
          // showGlobalUpdateAlert(text);
          runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => LoginProvider()),
                ChangeNotifierProvider(create: (_) => ManagerProvider()),
                ChangeNotifierProvider(create: (_) => BoysProvider()),
                ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  primarySwatch: Colors.blue,
                ),
                home: BoyBottomNavBar(boyID: id!,boyPhone: phone!,boyName:name!,isLockBool: true,),
              ),
            ),
          );
        }else{
          String address = map[Platform.isIOS ? "ADDRESS_iOS" : 'ADDRESS'].toString();
          String button = map['BUTTON'].toString();
          String text = map['TEXT'].toString();
          // showGlobalUpdateAlert(text);
          runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => LoginProvider()),
                ChangeNotifierProvider(create: (_) => ManagerProvider()),
                ChangeNotifierProvider(create: (_) => BoysProvider()),
                ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  primarySwatch: Colors.blue,
                ),
                home: SplashScreen(),
              ),
            ),
          );
        }
      }
    });
  }




  void lockAppGM() {
    mRoot.child("0").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        List<String> versions = Platform.isIOS
            ? map['iOSVersion'].toString().split(',')
            : map['GMAppVersions'].toString().split(',');

        print("Boys App Lock "+versions.toString() + ' ' + appVersion.toString());

        if (!versions.contains(appVersion)) {
          // bool versionStatus = await checkVersionExist();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? id = prefs.getString('adminID');
          String? name = prefs.getString('adminName');
          String? phone = prefs.getString('phone_number');

          String address = map[Platform.isIOS ? "ADDRESS_iOS" : 'ADDRESS'].toString();
          String button = map['BUTTON'].toString();
          String text = map['TEXT'].toString();
          // showGlobalUpdateAlert(text);

          print(' need to lock boy appp ');
          runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => LoginProvider()),
                ChangeNotifierProvider(create: (_) => ManagerProvider()),
                ChangeNotifierProvider(create: (_) => BoysProvider()),
                ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  primarySwatch: Colors.blue,
                ),
                home: ManagerBottom(adminPhone: phone!,adminName:name! ,adminID: id!,isLockBool: true,),
              ),
            ),
          );
        }
      }
    });
  }


  void reOpenGM() {
    mRoot.child("0").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        List<String> versions = Platform.isIOS
            ? map['iOSVersion'].toString().split(',')
            : map['GMAppVersions'].toString().split(',');

        print("Boys App Lock "+versions.toString() + ' ' + appVersion.toString());

        if (!versions.contains(appVersion)) {
          // bool versionStatus = await checkVersionExist();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? id = prefs.getString('adminID');
          String? name = prefs.getString('adminName');
          String? phone = prefs.getString('phone_number');

          String address = map[Platform.isIOS ? "ADDRESS_iOS" : 'ADDRESS'].toString();
          String button = map['BUTTON'].toString();
          String text = map['TEXT'].toString();
          // showGlobalUpdateAlert(text);

          print(' need to lock boy appp ');
          runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => LoginProvider()),
                ChangeNotifierProvider(create: (_) => ManagerProvider()),
                ChangeNotifierProvider(create: (_) => BoysProvider()),
                ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  primarySwatch: Colors.blue,
                ),
                home: ManagerBottom(adminPhone: phone!,adminName:name! ,adminID: id!,isLockBool: true,),
              ),
            ),
          );
        }else{
          runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => LoginProvider()),
                ChangeNotifierProvider(create: (_) => ManagerProvider()),
                ChangeNotifierProvider(create: (_) => BoysProvider()),
                ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  primarySwatch: Colors.blue,
                ),
                home: SplashScreen(),
              ),
            ),
          );
        }
      }
    });
  }




}