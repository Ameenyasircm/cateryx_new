import 'package:cateryyx/Constants/my_functions.dart';
import 'package:cateryyx/Manager/Models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Boys/Models/ConfirmedBoyModel.dart';

class EventDetailsProvider extends ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool isLoading = false;
  Map<String, dynamic>? eventData;
  List<Map<String, dynamic>> confirmedBoys = [];


  Future<void> addNote(String eventId, String note) async {
    try {
      await db.collection('EVENTS').doc(eventId).update({
        'NOTES': FieldValue.arrayUnion([note]),
      });

      // ✅ Update local state safely
      final List<String> notes =
      List<String>.from(eventData?['NOTES'] ?? []);
      notes.add(note);

      eventData?['NOTES'] = notes;

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> openGoogleMap(double latitude, double longitude) async {
    if (latitude == 0 || longitude == 0) {
      debugPrint("❌ Invalid coordinates");
      return;
    }

    final Uri googleMapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleMapUri)) {
        await launchUrl(
          googleMapUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("❌ Could not launch Google Maps");
      }
    } catch (e) {
      debugPrint("❌ Map launch error: $e");
    }
  }

  List<ConfirmedBoyModel> confirmedBoysList = [];

  Future<void> fetchConfirmedBoys(String eventId) async {
    confirmedBoysList.clear();
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await db
          .collection('EVENTS')
          .doc(eventId)
          .collection('CONFIRMED_BOYS')
          .orderBy('CONFIRMED_AT', descending: false)
          .get();

      for (var doc in snapshot.docs) {
        confirmedBoysList.add(
          ConfirmedBoyModel.fromMap(doc.data()),
        );
      }
    } catch (e) {
      debugPrint('❌ Fetch confirmed boys error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> markAttendance({
    required String eventId,
    required ConfirmedBoyModel boy,
    required String attendanceStatus,
    required String updatedById,
    required String updatedByName,
  }) async {
    final now = Timestamp.now();

    await db
        .collection('EVENTS')
        .doc(eventId)
        .collection('CONFIRMED_BOYS')
        .doc(boy.boyId)
        .update({
      'ATTENDANCE_STATUS': attendanceStatus,
      'ATTENDANCE_MARKED_AT': now,
      'ATTENDANCE_MARKED_BY': updatedById,
      'ATTENDANCE_MARKED_BY_NAME': updatedByName,
    });

    await db
        .collection('BOYS')
        .doc(boy.boyId)
        .collection('CONFIRMED_WORKS')
        .doc(eventId)
        .update({
      'ATTENDANCE_STATUS': attendanceStatus,
      'ATTENDANCE_MARKED_AT': now,
      'ATTENDANCE_MARKED_BY': updatedById,
      'ATTENDANCE_MARKED_BY_NAME': updatedByName,
    });

    final index =
    confirmedBoysList.indexWhere((e) => e.boyId == boy.boyId);

    confirmedBoysList[index] = boy.copyWith(
      attendanceStatus: attendanceStatus,
      attendanceMarkedAt: now,
    );

    notifyListeners();
  }

  Future<void> saveBoyPayment({
    required String eventId,
    required String boyId,
    required double amount,
  }) async {
    await db
        .collection('EVENTS')
        .doc(eventId)
        .collection('CONFIRMED_BOYS')
        .doc(boyId)
        .update({
      'PAYMENT_AMOUNT': amount,
      'PAYMENT_UPDATED_AT': Timestamp.now(),
    });

    await db
        .collection('BOYS')
        .doc(boyId)
        .collection('CONFIRMED_WORKS')
        .doc(eventId)
        .update({
      'PAYMENT_AMOUNT': amount,
      'PAYMENT_UPDATED_AT': Timestamp.now(),
    });

    final index =
    confirmedBoysList.indexWhere((e) => e.boyId == boyId);

    confirmedBoysList[index] =
        confirmedBoysList[index].copyWith(paymentAmount: amount);

    notifyListeners();
  }

  Future<void> updateWorkActiveStatus({
    required String eventId,
    required bool isActive,
  }) async {
    final status = isActive ? "ACTIVE" : "DEACTIVE";

    await db
        .collection('EVENTS')
        .doc(eventId)
        .update({
      'WORK_ACTIVE_STATUS': status,
    });

    notifyListeners();
  }

  void copyEventDetails(String location,String date, BuildContext context) {

    StringBuffer text = StringBuffer();

    text.writeln("SITE         : ${location}");
    text.writeln("WORK DATE    : ${date}");
    text.writeln("");
    text.writeln("Confirmed Boys");
    text.writeln("");

    for (int i = 0; i < confirmedBoysList.length; i++) {
      final b = confirmedBoysList[i];
      text.writeln("${i + 1}. ${b.boyName} - ${b.boyPhone}");
    }

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: text.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to Clipboard")),
    );
  }



  /// Generate search prefixes from a text
  List<String> generateKeywords(String text) {
    text = text.toLowerCase().trim();
    List<String> keywords = [];

    for (int i = 1; i <= text.length; i++) {
      keywords.add(text.substring(0, i));
    }

    return keywords;
  }

  /// Run this ONCE to update all boys
  Future<void> updateAllBoysSearchKeywords() async {
    final db = FirebaseFirestore.instance;

    try {
      QuerySnapshot snap = await db.collection('BOYS').get();

      for (var doc in snap.docs) {
        String name = (doc.data() as Map<String, dynamic>)['NAME'] ?? '';
        String phone = (doc.data() as Map<String, dynamic>)['PHONE'] ?? '';

        // Generate name keywords
        List<String> nameKeywords = generateKeywords(name);

        // Generate keywords for each word in the name
        if (name.contains(" ")) {
          name.split(" ").forEach((part) {
            nameKeywords.addAll(generateKeywords(part));
          });
        }

        // Generate phone keywords
        List<String> phoneKeywords = generateKeywords(phone);

        // Merge + remove duplicates
        List<String> finalKeywords = {
          ...nameKeywords,
          ...phoneKeywords,
        }.toList();

        // Update Firestore
        await db.collection('BOYS').doc(doc.id).set(
          {
            "SEARCH_KEYWORDS": finalKeywords,
          },
          SetOptions(merge: true),
        );

        print("Updated ${doc.id}");
      }

      print("All boys updated successfully!");
    } catch (e) {
      print("Error: $e");
    }
  }


  Future<List<Map<String, dynamic>>> searchBoys(String query) async {
    if (query.trim().isEmpty) return [];

    final result = await FirebaseFirestore.instance
        .collection('BOYS')
        .where('SEARCH_KEYWORDS', arrayContains: query.toLowerCase().trim())
        .where('STATUS', isEqualTo: 'APPROVED')
        .limit(20)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  bool addBoyBool=false;
  Future<void> managerAssignBoyToEvent(
      String eventId, String boyId) async {

    addBoyBool = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminName = prefs.getString('adminName');
    String? adminID = prefs.getString('adminID');

    final boyDoc = await db.collection('BOYS').doc(boyId).get();
    if (!boyDoc.exists) throw Exception("Boy not found");

    final boy = boyDoc.data()!;

    final eventRef = db.collection('EVENTS').doc(eventId);
    final confirmedBoyRef = eventRef.collection('CONFIRMED_BOYS').doc(boyId);
    final boyWorkRef = db
        .collection('BOYS')
        .doc(boyId)
        .collection('CONFIRMED_WORKS')
        .doc(eventId);

    await db.runTransaction((transaction) async {
      final eventSnap = await transaction.get(eventRef);
      if (!eventSnap.exists) throw Exception("Event not found");

      final data = eventSnap.data()!;
      final int required = data['BOYS_REQUIRED'] ?? 0;
      final int taken = data['BOYS_TAKEN'] ?? 0;

      if (taken >= required) throw Exception("All slots filled");

      if ((await transaction.get(confirmedBoyRef)).exists)
        throw Exception("Boy already added");

      if ((await transaction.get(boyWorkRef)).exists)
        throw Exception("Already assigned");

      final updatedTaken = taken + 1;

      transaction.update(eventRef, {
        'BOYS_TAKEN': updatedTaken,
        if (updatedTaken == required) 'BOYS_STATUS': 'FULL',
      });

      final minimalEventData = {
        'ADDED_BY_ID': adminID,
        'ADDED_BY_NAME': adminName,
        'EVENT_ID': eventId,
        'BOY_ID': boyId,
        'BOY_NAME': boy['NAME'],
        'BOY_PHONE': boy['PHONE'],
        'STATUS': 'CONFIRMED',
        'ATTENDANCE_STATUS': 'PENDING',
        'CONFIRMED_AT': FieldValue.serverTimestamp(),
        'EVENT_NAME': data['EVENT_NAME'],
        'EVENT_DATE': data['EVENT_DATE'],
        'EVENT_DATE_TS': data['EVENT_DATE_TS'],
        'LOCATION_NAME': data['LOCATION_NAME'],
      };

      transaction.set(confirmedBoyRef, minimalEventData);
      transaction.set(boyWorkRef, minimalEventData);
    });
    fetchSingleEvent(eventId);
    await fetchConfirmedBoys(eventId);

    addBoyBool = false;
    notifyListeners();
  }
  bool removeBoyLoader = false;

  Future<void> removeBoyFromEvent(String eventId, String boyId,BuildContext context) async {
    removeBoyLoader = true;
    notifyListeners();

    try {
      final eventRef = db.collection('EVENTS').doc(eventId);
      final confirmedBoyRef = eventRef.collection('CONFIRMED_BOYS').doc(boyId);
      final boyWorkRef = db
          .collection('BOYS')
          .doc(boyId)
          .collection('CONFIRMED_WORKS')
          .doc(eventId);

      await db.runTransaction((transaction) async {
        final eventSnap = await transaction.get(eventRef);
        if (!eventSnap.exists) throw Exception("Event not found");

        final data = eventSnap.data()!;
        final int taken = data['BOYS_TAKEN'] ?? 0;
        if (taken <= 0) throw Exception("No boys assigned");

        final boyInEvent = await transaction.get(confirmedBoyRef);
        if (!boyInEvent.exists) throw Exception("Boy not assigned");

        final updatedTaken = taken - 1;

        transaction.update(eventRef, {
          'BOYS_TAKEN': updatedTaken,
          if (updatedTaken < (data['BOYS_REQUIRED'] ?? 0))
            'BOYS_STATUS': 'AVAILABLE',
        });

        transaction.delete(confirmedBoyRef);
        transaction.delete(boyWorkRef);
      });

      /// ❌ Your previous code was wrong
      /// confirmedBoysList.removeAt(confirmedBoysList.where(...))

      /// ✔ Correct way:
      confirmedBoysList.removeWhere((e) => e.boyId == boyId);

      await fetchConfirmedBoys(eventId);
    } catch (e) {
      print("Error removing boy: $e");
    }
    fetchSingleEvent(eventId);
    removeBoyLoader = false;
    notifyListeners();

    finish(context);
  }

  EventModel? eventModel;

  void setEventModelData(EventModel data){
    eventModel = data;
    notifyListeners();
  }

  Future<void> fetchSingleEvent(String eventId) async {
    final snap = await db.collection('EVENTS').doc(eventId).get();
    if (snap.exists) {
      eventModel = EventModel.fromMap(snap.data()!);
      notifyListeners();
    }
  }







}



