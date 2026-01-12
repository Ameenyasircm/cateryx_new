import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


String formatDate(Timestamp timestamp) {
return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
}

 String formatTime(Timestamp timestamp) {
return DateFormat('hh:mm a').format(timestamp.toDate());
}
