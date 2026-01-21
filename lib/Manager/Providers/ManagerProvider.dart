import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/appConfig.dart';
import '../../core/utils/snackBarNotifications/snackBar_notifications.dart';
import '../Models/BoysRequestModel.dart';
import '../Models/event_model.dart';
import '../Screens/LoginScreen.dart';

class ManagerProvider extends ChangeNotifier{

  final FirebaseFirestore db = FirebaseFirestore.instance;


  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;


  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }


  // Controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController boysController = TextEditingController();
  DateTime? eventDateTime;
  String selectedMeal = 'Lunch';

  /// 📅 Date Picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1A237E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      eventDateTime=picked;
      notifyListeners();
    }
  }

  /// 🍽 Meal Change
  void changeMeal(String value) {
    selectedMeal = value;
    notifyListeners();
  }

  void clearEventRegScreens() {
    dateController.clear();
    nameController.clear();
    descController.clear();
    locationController.clear();
    boysController.clear();
  }

  double? latitude;
  double? longitude;

  /// 📍 Save picked location
  void setLocation({
    required String address,
    required double lat,
    required double lng,
  }) {
    locationController.text = address;
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }


  PublishType publishType = PublishType.now;

  void changePublishType(PublishType type) {
    publishType = type;
    notifyListeners();
  }

  Future<void> createEventFun(BuildContext context) async {
    if (eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select event date")),
      );
      return;
    }

    try {
      final String eventId = "EVT${DateTime.now().millisecondsSinceEpoch}";
      final String eventName = nameController.text.trim();
      final String location = locationController.text.trim();

      // ------------------------------
      // 🔥 Generate Search Keywords
      // ------------------------------

      /// 1. Event name keywords
      List<String> eventKeywords = generateKeywords(eventName);

      /// 2. Event name word-wise
      if (eventName.contains(" ")) {
        eventName.split(" ").forEach((word) {
          eventKeywords.addAll(generateKeywords(word));
        });
      }

      /// 3. Location keywords
      List<String> locationKeywords = generateKeywords(location);

      /// 4. Location word-wise
      if (location.contains(" ")) {
        location.split(" ").forEach((word) {
          locationKeywords.addAll(generateKeywords(word));
        });
      }

      /// 5. Merge both & remove duplicates
      final List<String> finalKeywords = {
        ...eventKeywords,
        ...locationKeywords,
      }.toList();

      // ------------------------------
      // 🔥 FIRESTORE SAVE
      // ------------------------------

      await db.collection("EVENTS").doc(eventId).set({
        "EVENT_ID": eventId,
        "EVENT_NAME": eventName,

        /// 👇 BOTH FORMATS
        "EVENT_DATE": dateController.text.trim(),
        "EVENT_DATE_TS": Timestamp.fromDate(eventDateTime!),

        'WORK_ACTIVE_STATUS': 'ACTIVE',
        "MEAL_TYPE": selectedMeal,
        "LOCATION_NAME": location,
        "LATITUDE": latitude,
        "LONGITUDE": longitude,
        "BOYS_REQUIRED": int.parse(boysController.text),
        "DESCRIPTION": descController.text.trim(),
        "STATUS": "CREATED",
        "CREATED_TIME": FieldValue.serverTimestamp(),

        /// 👇 Publish Status
        "STATUS": publishType == PublishType.now ? "PUBLISHED" : "DRAFT",
        "EVENT_STATUS":
        publishType == PublishType.now ? "UPCOMING" : "NOT_PUBLISHED",

        /// 👇 Final merged keywords
        "SEARCH_KEYWORDS": finalKeywords,
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event created successfully")),
      );

      fetchRunningEvents();
    } catch (e) {
      debugPrint("Create Event Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create event")),
      );
    }
  }


  bool isLoading = false;

  List<EventModel> upcomingEventsList = [];
  List<EventModel> runningEventsList = [];

  /// 🔥 FETCH EVENTS
  Future<void> fetchUpcomingEvents() async {
    upcomingEventsList.clear();
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await db
          .collection('EVENTS').where('STATUS',isEqualTo: 'DRAFT')
          // .orderBy('EVENT_DATE_TS', descending: false)
          .get();


      for (var doc in snapshot.docs) {
        upcomingEventsList.add(EventModel.fromMap(doc.data()));
      }
      print(upcomingEventsList.length.toString()+' FRNFRJKF ');
    } catch (e) {
      debugPrint("Fetch Events Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRunningEvents() async {
    runningEventsList.clear();
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await db
          .collection('EVENTS').where('STATUS',isEqualTo: 'PUBLISHED')
      // .orderBy('EVENT_DATE_TS', descending: false)
          .get();


      for (var doc in snapshot.docs) {
        runningEventsList.add(EventModel.fromMap(doc.data()));
      }
    } catch (e) {
      debugPrint("Fetch Events Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }



  Future<void> updateBoyPassword(BuildContext context, String docId, String newPassword,String fromWhere) async {
    try {
      String dbName='';
      if(fromWhere=="boy"){
        dbName="BOYS";
      }else{
        dbName="ADMINS";
      }

      await db.collection(dbName).doc(docId).set({
        "PASSWORD": newPassword, // Stored as a string
        "PASSWORD_UPDATED_TIME": FieldValue.serverTimestamp()
      },SetOptions(merge: true));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('password', newPassword);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Password updated successfully!")),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Update Password Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update password. Please try again.")),
        );
      }
      rethrow; // Pass error back to the UI to stop loading state
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
          (route) => false,
    );
  }


  List<BoyRequestModel> pendingBoysList = [];

  /// 🔹 FETCH PENDING BOYS
  Future<void> fetchPendingBoysRequests() async {
    pendingBoysList.clear();
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await db
          .collection('BOYS')
          .where('STATUS', isEqualTo: 'PENDING')
          // .orderBy('CREATED_TIME', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        pendingBoysList.add(
          BoyRequestModel.fromDoc(doc.data(), doc.id),
        );
      }
    } catch (e) {
      debugPrint("Fetch Boys Request Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ APPROVE
  Future<void> approveBoy(String docId) async {
    await db.collection('BOYS').doc(docId).update({
      'STATUS': 'APPROVED',
      'APPROVED_TIME': FieldValue.serverTimestamp(),
    });

    pendingBoysList.removeWhere((e) => e.docId == docId);
    notifyListeners();
  }

  /// ❌ REJECT
  Future<void> rejectBoy(String docId) async {
    await db.collection('BOYS').doc(docId).update({
      'STATUS': 'REJECTED',
      'REJECTED_TIME': FieldValue.serverTimestamp(),
    });

    pendingBoysList.removeWhere((e) => e.docId == docId);
    notifyListeners();
  }


  Future<void> updateBoyStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('BOYS')
        .doc(docId)
        .update({
      'STATUS': status,
      'APPROVED_TIME': FieldValue.serverTimestamp(),
    });

    pendingBoysList.removeWhere((e) => e.docId == docId);
    notifyListeners();
  }
  /// boy work history
  bool isLoadingWrkHistory = true;
  List<Map<String, dynamic>> workHistory = [];

  Future<void> fetchBoyWorkHistory(String boyId) async {
    isLoadingWrkHistory = true;
    notifyListeners();

    try {
      final querySnapshot = await db
          .collection('BOYS')
          .doc(boyId)
          .collection('CONFIRMED_WORKS')
          .where('STATUS', isEqualTo: 'CONFIRMED')
          .orderBy('EVENT_DATE_TS', descending: true)
          .get();

      workHistory = querySnapshot.docs
          .map((doc) => {
        ...doc.data(),
        'DOC_ID': doc.id,
      })
          .toList();
    } catch (e) {
      debugPrint('Error fetching work history: $e');
      NotificationSnack.showError(e.toString());
    } finally {
      /// ✅ THIS WAS MISSING / WRONG
      isLoadingWrkHistory = false;
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



}

