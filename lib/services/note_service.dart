import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NotesService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addNote({
    required String eventId,
    required NoteModel note,
  }) async {
    await db
        .collection("EVENTS")
        .doc(eventId)
        .collection("NOTES")
        .doc(note.id)
        .set(note.toJson(), SetOptions(merge: true));
  }

  Stream<List<NoteModel>> getNotes(String eventId) {
    return db
        .collection("EVENTS")
        .doc(eventId)
        .collection("NOTES")
        .orderBy("createdTime", descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((e) => NoteModel.fromJson(e.data()))
        .toList());
  }
}
