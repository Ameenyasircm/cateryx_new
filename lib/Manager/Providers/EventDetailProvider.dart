import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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


}



