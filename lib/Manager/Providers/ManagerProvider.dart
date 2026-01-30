import 'dart:io';
import 'package:cateryyx/Constants/my_functions.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/appConfig.dart';
import '../../core/utils/snackBarNotifications/snackBar_notifications.dart';
import '../Models/BoysRequestModel.dart';
import '../Models/closed_event_model.dart';
import '../Models/event_model.dart';
import '../Models/payment_report_model.dart';
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
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientPhoneController = TextEditingController();
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
    clientNameController.clear();
    clientPhoneController.clear();
    notifyListeners();
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

        "EVENT_DATE": dateController.text.trim(),
        "EVENT_DATE_TS": Timestamp.fromDate(eventDateTime!),

        'WORK_ACTIVE_STATUS': 'ACTIVE',
        "MEAL_TYPE": selectedMeal,
        "LOCATION_NAME": location,
        "LATITUDE": latitude,
        "LONGITUDE": longitude,
        "BOYS_REQUIRED": int.parse(boysController.text),
        "DESCRIPTION": descController.text.trim(),

        /// 👉 NEW FIELDS
        "CLIENT_NAME": clientNameController.text.trim(),
        "CLIENT_PHONE": clientPhoneController.text.trim(),

        "STATUS": publishType == PublishType.now ? "PUBLISHED" : "DRAFT",
        "EVENT_STATUS":
        publishType == PublishType.now ? "UPCOMING" : "NOT_PUBLISHED",

        "CREATED_TIME": FieldValue.serverTimestamp(),

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

  Future<void> publishEvent(String eventId,BuildContext context) async {
    final prefs=await SharedPreferences.getInstance();
    String adminId=prefs.getString('adminID')??"";
    String adminName=prefs.getString('adminName')??"";
    String adminPhone=prefs.getString('phone_number')??"";
     db.collection("EVENTS").doc(eventId).set({
       'STATUS':'PUBLISHED',
       'EVENT_STATUS':'UPCOMING',
       'EVENT_PUBLISHED_BY':adminName,
       'EVENT_PUBLISHED_BY_ID':adminId,
       'EVENT_PUBLISHED_BY_PHONE':adminPhone,
       'PUBLISHED_TIME':FieldValue.serverTimestamp(),

     },SetOptions(merge: true));
    upcomingEventsList.removeWhere((e) => e.eventId == eventId);
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Event published successfully")),
     );
     notifyListeners();
  }

  Future<void> editEventFun(
      BuildContext context,
      String eventId,
      EventDetailsProvider eventProvider,
      ) async {
    try {
      final eventRef = db.collection("EVENTS").doc(eventId);

      // -------------------------------------------------
      // 🔍 STEP 1: Check if at least one boy has taken the work
      // -------------------------------------------------
      final boysSnap =
      await eventRef.collection("CONFIRMED_BOYS").limit(1).get();

      final bool boysTaken = boysSnap.docs.isNotEmpty;

      // =================================================
      // 🟡 IF BOYS TAKEN → Do NOT allow event name & date edit
      // =================================================
      if (boysTaken) {
        await eventRef.set({
          // ❌ Event name NOT updated
          // ❌ Event date NOT updated

          "MEAL_TYPE": selectedMeal,
          "LOCATION_NAME": locationController.text.trim(),
          "LATITUDE": latitude,
          "LONGITUDE": longitude,
          "BOYS_REQUIRED": int.parse(boysController.text),
          "DESCRIPTION": descController.text.trim(),

          /// 👉 NEW FIELDS (Still allowed to edit)
          "CLIENT_NAME": clientNameController.text.trim(),
          "CLIENT_PHONE": clientPhoneController.text.trim(),

          "STATUS": publishType == PublishType.now ? "PUBLISHED" : "DRAFT",
          "EVENT_STATUS":
          publishType == PublishType.now ? "UPCOMING" : "NOT_PUBLISHED",

          "UPDATED_TIME": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        eventProvider.fetchSingleEvent(eventId);
        finish(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Event updated.\nEvent name and date cannot be edited because boys have already taken this work.",
            ),
          ),
        );

        return;
      }

      // =================================================
      // 🟢 NO BOYS TAKEN → FULL EDIT ALLOWED
      // =================================================

      final String eventName = nameController.text.trim();
      final String location = locationController.text.trim();

      // 🔥 Keyword regeneration
      List<String> eventKeywords = generateKeywords(eventName);
      if (eventName.contains(" ")) {
        for (var w in eventName.split(" ")) {
          eventKeywords.addAll(generateKeywords(w));
        }
      }

      List<String> locationKeywords = generateKeywords(location);
      if (location.contains(" ")) {
        for (var w in location.split(" ")) {
          locationKeywords.addAll(generateKeywords(w));
        }
      }

      final List<String> finalKeywords = {
        ...eventKeywords,
        ...locationKeywords,
      }.toList();

      // =================================================
      // 🔥 FULL UPDATE
      // =================================================
      await eventRef.set({
        "EVENT_NAME": eventName,
        "EVENT_DATE": dateController.text.trim(),
        "EVENT_DATE_TS": Timestamp.fromDate(eventDateTime!),

        "MEAL_TYPE": selectedMeal,
        "LOCATION_NAME": location,
        "LATITUDE": latitude,
        "LONGITUDE": longitude,

        "BOYS_REQUIRED": int.parse(boysController.text),
        "DESCRIPTION": descController.text.trim(),

        /// 👉 NEW FIELDS
        "CLIENT_NAME": clientNameController.text.trim(),
        "CLIENT_PHONE": clientPhoneController.text.trim(),

        "STATUS": publishType == PublishType.now ? "PUBLISHED" : "DRAFT",
        "EVENT_STATUS":
        publishType == PublishType.now ? "UPCOMING" : "NOT_PUBLISHED",

        "SEARCH_KEYWORDS": finalKeywords,
        "UPDATED_TIME": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      eventProvider.fetchSingleEvent(eventId);
      finish(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event updated successfully")),
      );
    } catch (e) {
      debugPrint("Edit Event Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update event")),
      );
    }
  }

  bool lockNameAndDate = false;

  Future<void> loadEventForEdit(String eventId) async {
    final eventRef = db.collection("EVENTS").doc(eventId);

    // Check if boys have taken the work → lock some fields
    final boysSnap =
    await eventRef.collection("CONFIRMED_BOYS").limit(1).get();
    lockNameAndDate = boysSnap.docs.isNotEmpty;

    final data = (await eventRef.get()).data()!;

    // 👇 fill values
    nameController.text = data["EVENT_NAME"];
    dateController.text = data["EVENT_DATE"];
    selectedMeal = data["MEAL_TYPE"];
    locationController.text = data["LOCATION_NAME"];

    latitude = data["LATITUDE"];
    longitude = data["LONGITUDE"];
    boysController.text = data["BOYS_REQUIRED"].toString();
    descController.text = data["DESCRIPTION"];

    // 👉 NEW FIELDS (Safe access)
    clientNameController.text = data["CLIENT_NAME"] ?? "";
    clientPhoneController.text = data["CLIENT_PHONE"] ?? "";

    // Set actual DateTime from Timestamp
    if (data["EVENT_DATE_TS"] != null) {
      eventDateTime = (data["EVENT_DATE_TS"] as Timestamp).toDate();
    }

    notifyListeners();
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
      print('${upcomingEventsList.length} FRNFRJKF ');
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


  Future<void> updateBoyStatus(String docId, String status, double wage) async {
    await FirebaseFirestore.instance
        .collection('BOYS')
        .doc(docId)
        .update({
      'STATUS': status,
      'WAGE': wage, // number stored in DB
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

  Future<void> closeEvent(String eventId) async {
    final prefs=await SharedPreferences.getInstance();
    String adminId=prefs.getString('adminID')??"";
    String adminName=prefs.getString('adminName')??"";
    String adminPhone=prefs.getString('phone_number')??"";
    await db.collection('EVENTS').doc(eventId).update({
      'STATUS': 'CLOSED',
      'WORK_ACTIVE_STATUS':'CLOSED',
      'WORK_CLOSED_BY':adminName,
      'WORK_CLOSED_BY_ID':adminId,
      'WORK_CLOSED_BY_PHONE':adminPhone,
      'CLOSED_TIME': FieldValue.serverTimestamp(),
    });

    runningEventsList.removeWhere((e) => e.eventId == eventId);
    notifyListeners();
  }



  final List<PaymentReportModel> reportList = [];        // filtered list for UI
  final List<PaymentReportModel> _allReportList = [];    // full list backup



  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;

  final int limit = 20;
  DocumentSnapshot? lastDoc;

  // ✅ Filters
  DateTime? fromDate;
  DateTime? toDate;
  String searchText = "";

  void applyLocalSearch(String value) {
    searchText = value.trim();

    if (searchText.isEmpty) {
      reportList
        ..clear()
        ..addAll(_allReportList);
      notifyListeners();
      return;
    }

    final search = searchText.toLowerCase();

    reportList
      ..clear()
      ..addAll(
        _allReportList.where((m) {
          final name = m.boyName.toLowerCase();
          final phone = m.boyPhone.toLowerCase();
          return name.contains(search) || phone.contains(search);
        }).toList(),
      );

    notifyListeners();
  }


  // ✅ Set date range
  void setDateRange({DateTime? from, DateTime? to}) {
    fromDate = from;
    toDate = to;
    fetchFirstPage();
  }

  void clearFilters() {
    fromDate = null;
    toDate = null;
    searchText = "";
    fetchFirstPage();
  }


  Future<void> fetchFirstPage({String? boyId}) async {
    loading = true;

    reportList.clear();
    _allReportList.clear();

    lastDoc = null;
    hasMore = true;
    notifyListeners();

    try {
      Query query = db
          .collection("PAYMENTS_REPORT")
          .orderBy("PAYMENT_UPDATED_AT", descending: true)
          .limit(limit);

      // ✅ If Boy module => filter only boyId
      if (boyId != null && boyId.isNotEmpty) {
        query = query.where("BOY_ID", isEqualTo: boyId);
      }

      // ✅ Date Filter (Optional)
      if (fromDate != null && toDate != null) {
        query = query
            .where("PAYMENT_UPDATED_AT", isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate!))
            .where("PAYMENT_UPDATED_AT", isLessThanOrEqualTo: Timestamp.fromDate(
            DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59)));
      }

      final snap = await query.get();
      if (snap.docs.isNotEmpty) lastDoc = snap.docs.last;

      final data = snap.docs.map((e) => PaymentReportModel.fromDoc(e)).toList();

      _allReportList.addAll(data);
      reportList.addAll(data);

      hasMore = snap.docs.length == limit;
    } catch (e) {
      debugPrint("fetchFirstPage error: $e");
    }

    loading = false;
    notifyListeners();
  }



  Future<void> fetchMore({String? boyId}) async {
    if (!hasMore || loadingMore || lastDoc == null) return;

    loadingMore = true;
    notifyListeners();

    try {
      Query query = db
          .collection("PAYMENTS_REPORT")
          .orderBy("PAYMENT_UPDATED_AT", descending: true)
          .startAfterDocument(lastDoc!)
          .limit(limit);

      if (boyId != null && boyId.isNotEmpty) {
        query = query.where("BOY_ID", isEqualTo: boyId);
      }

      final snap = await query.get();
      if (snap.docs.isNotEmpty) lastDoc = snap.docs.last;

      final data = snap.docs.map((e) => PaymentReportModel.fromDoc(e)).toList();

      _allReportList.addAll(data);

      applyLocalSearch(searchText);

      hasMore = snap.docs.length == limit;
    } catch (e) {
      debugPrint("fetchMore error: $e");
    }

    loadingMore = false;
    notifyListeners();
  }



  String formatDateTime(DateTime? inputDate) {
    if (inputDate == null) return " ";
    return DateFormat('dd MMM yy hh:mm a').format(inputDate);
  }

}

