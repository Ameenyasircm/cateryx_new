import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/appConfig.dart';
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

    // if (latitude == null || longitude == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please select event location")),
    //   );
    //   return;
    // }

    try {
      final String eventId =
          "EVT${DateTime.now().millisecondsSinceEpoch}";

      await db.collection("EVENTS").doc(eventId).set({
        "EVENT_ID": eventId,
        "EVENT_NAME": nameController.text.trim(),

        /// 👇 BOTH FORMATS
        "EVENT_DATE": dateController.text.trim(),
        "EVENT_DATE_TS": Timestamp.fromDate(eventDateTime!),

        "MEAL_TYPE": selectedMeal,
        "LOCATION_NAME": locationController.text.trim(),
        "LATITUDE": latitude,
        "LONGITUDE": longitude,
        "BOYS_REQUIRED": int.parse(boysController.text),
        "DESCRIPTION": descController.text.trim(),
        "STATUS": "CREATED",
        "CREATED_TIME": FieldValue.serverTimestamp(),
        "STATUS": publishType == PublishType.now ? "PUBLISHED" : "DRAFT",
        "EVENT_STATUS": publishType == PublishType.now ? "UPCOMING" : "NOT_PUBLISHED",
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event created successfully")),
      );
      fetchUpcomingEvents();
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



  Future<void> updateBoyPassword(BuildContext context, String docId, String newPassword) async {
    try {

      await db.collection("ADMINS").doc(docId).set({
        "PASSWORD": newPassword, // Stored as a string
        "PASSWORD_UPDATED_TIME": FieldValue.serverTimestamp()
      },SetOptions(merge: true));

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
}

