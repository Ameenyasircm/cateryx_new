import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

}
