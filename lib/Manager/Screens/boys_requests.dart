import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Boys/Screens/boy_registration.dart';
import '../Models/BoysRequestModel.dart';
import '../Providers/ManagerProvider.dart';


class BoysRequestScreen extends StatelessWidget {
  const BoysRequestScreen({super.key});

  Widget build(BuildContext context) {
    ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      appBar: AppBar(
        title: const Text("Boys Requests"),
        backgroundColor: const Color(0xff1A237E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, value, _) {

          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (value.pendingBoysList.isEmpty) {
            return const Center(child: Text("No pending requests"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: value.pendingBoysList.length,
            itemBuilder: (context, index) {
              final doc = value.pendingBoysList[index];
              return _boyTile(context, doc);
            },
          );
        },
      ),
    );
  }

  Widget _boyTile(BuildContext context, BoyRequestModel doc) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xffE8EAF6),
          child: Icon(Icons.person, color: Color(0xff1A237E)),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(doc.phone),
        trailing: const Icon(Icons.chevron_right_rounded),
        // onTap: () => _showBoyDetails(context, doc),
        onTap: (){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterBoyScreen(
                registeredBy: "MANAGER",
                editBoyModel: doc, // 👈 pass full model
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: "$title : ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

