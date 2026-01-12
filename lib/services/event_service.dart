import 'package:cloud_firestore/cloud_firestore.dart';
import '../Manager/Models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all events
  Future<List<EventModel>> fetchAllEvents() async {
    try {
      final snapshot = await _db
          .collection('EVENTS')
          .where('EVENT_STATUS',isEqualTo: 'UPCOMING')
          .orderBy('EVENT_DATE_TS', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch upcoming events
  Future<List<EventModel>> fetchUpcomingEvents(String userId) async {
    try {
      // 1️⃣ Get today's UTC start
      final nowUtc = DateTime.now().toUtc();
      final startOfTodayUtc =
      DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

      // 2️⃣ Fetch upcoming events
      final eventsSnapshot = await _db
          .collection('EVENTS')
          .where(
        'EVENT_DATE_TS',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(startOfTodayUtc),
      )
          .orderBy('EVENT_DATE_TS')
          .get();

      final events = eventsSnapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();

      // 3️⃣ Fetch confirmed works of this boy
      final confirmedSnapshot = await _db
          .collection('BOYS')
          .doc(userId)
          .collection('CONFIRMED_WORKS')
          .get();

      final confirmedEventIds =
      confirmedSnapshot.docs.map((d) => d.id).toSet();

      // 4️⃣ Remove already confirmed events
      events.removeWhere(
            (event) => confirmedEventIds.contains(event.eventId),
      );

      return events;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }


  /// Take a work
  Future<void> takeWork(String eventId,String boyId) async {
    // 🔹 Read from SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // final String boyId = prefs.getString('boyId') ?? '';
    final String boyName = prefs.getString('boyName') ?? '';
    final String boyPhone = prefs.getString('boyPhone') ?? '';

    if (boyId.isEmpty) {
      throw Exception('Boy not logged in');
    }

    final eventRef = _db.collection('EVENTS').doc(eventId);

    final confirmedBoyRef =
    eventRef.collection('CONFIRMED_BOYS').doc(boyId);

    final boyWorkRef = _db
        .collection('BOYS')
        .doc(boyId)
        .collection('CONFIRMED_WORKS')
        .doc(eventId);

    await _db.runTransaction((transaction) async {
      // 1️⃣ Read Event
      final eventSnap = await transaction.get(eventRef);
      if (!eventSnap.exists) {
        throw Exception('Event not found');
      }

      final data = eventSnap.data()!;
      final int required = data['BOYS_REQUIRED'] ?? 0;
      final int taken = data['BOYS_TAKEN'] ?? 0;

      // 2️⃣ Check capacity
      if (taken >= required) {
        throw Exception('All slots are already filled');
      }

      // 3️⃣ Prevent duplicate booking
      if ((await transaction.get(confirmedBoyRef)).exists) {
        throw Exception('You already took this work');
      }

      if ((await transaction.get(boyWorkRef)).exists) {
        throw Exception('Work already exists for this boy');
      }

      final int updatedTaken = taken + 1;

      // 4️⃣ Update EVENT
      transaction.update(eventRef, {
        'BOYS_TAKEN': updatedTaken,
        if (updatedTaken == required) 'BOYS_STATUS': 'FULL',
      });

      // 5️⃣ EVENTS → CONFIRMED_BOYS
      transaction.set(confirmedBoyRef, {
        ...data,
        'BOY_ID': boyId,
        'BOY_NAME': boyName,
        'BOY_PHONE': boyPhone,
        'STATUS': 'CONFIRMED',
        'CONFIRMED_AT': FieldValue.serverTimestamp(),
      });

      // 6️⃣ BOYS → CONFIRMED_WORKS
      transaction.set(boyWorkRef, {
        ...data,
        'EVENT_ID': eventId,
        'BOY_ID': boyId,
        'BOY_NAME': boyName,
        'BOY_PHONE': boyPhone,
        'STATUS': 'CONFIRMED',
        'CONFIRMED_AT': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<EventModel>> fetchConfirmedWorks(String userId) async {
    try {
      final snapshot = await _db
          .collection('BOYS')
          .doc(userId)
          .collection('CONFIRMED_WORKS')
          .orderBy('CONFIRMED_AT', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }






}
