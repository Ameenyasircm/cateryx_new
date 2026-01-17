import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/alert_utils.dart';
import '../../core/utils/work_manage_boys_utils.dart';
import '../Providers/EventDetailProvider.dart';

class EventAttendanceScreen extends StatelessWidget {
  final String eventId;

  const EventAttendanceScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.confirmedBoysList.length,
            itemBuilder: (context, index) {
              final boy = provider.confirmedBoysList[index];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(boy.boyName),
                subtitle: Text(boy.boyPhone),
                trailing: GestureDetector(
                  onTap: () {
                    showAttendanceChoiceDialog(
                      context: context,
                      boyName: boy.boyName,
                      onConfirm: (status) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();

                        await provider.markAttendance(
                          eventId: eventId,
                          boy: boy,
                          attendanceStatus: status,
                          updatedById: prefs.getString('adminID') ?? '',
                          updatedByName: prefs.getString('adminName') ?? '',
                        );

                        showSuccessAlert(
                          context: context,
                          title: "Updated",
                          message: "${boy.boyName} marked as $status",
                        );
                      },
                    );
                  },
                  child: Chip(
                    label: Text(boy.attendanceStatus),
                    backgroundColor:
                    attendanceColor(boy.attendanceStatus).withOpacity(0.15),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
