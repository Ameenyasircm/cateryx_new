
import 'package:cateryyx/Boys/Screens/home/widgets/work_card.dart';
import 'package:flutter/material.dart';

import '../../../../Constants/my_functions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/alert_utils.dart';
import '../../../../core/utils/date_time_parser.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/loader/loader.dart';
import '../../../../core/utils/snackBarNotifications/snackBar_notifications.dart';
import '../../../../core/utils/text_utils.dart';
import '../../../../services/event_service.dart';
import '../work_details_screen.dart';

class WorkTabs extends StatelessWidget {
  const WorkTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:  [
        TabBar(
          unselectedLabelStyle: AppTypography.body1,
          labelStyle: AppTypography.body1,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Available Works',),
            Tab(text: 'Confirmed Work'),
          ],
        ),
      ],
    );
  }
}

class AvailableWorksTab extends StatelessWidget {
  final String userId;
   AvailableWorksTab({super.key,required this.userId});
  final EventService _service = EventService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _service.fetchUpcomingEvents(userId),
        builder: (context4, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return  Center(child: Text('No events found',style: AppTypography.body2,));
          }
        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          itemBuilder: (context7,index){

            final event = events[index];
            return  InkWell(
              onTap: () async {

                final confirmed = await showConfirmDialog(
                  context: context,
                  title: 'Take this work?',
                  message: 'Do you want to take ${event.eventName}?',
                  confirmText: 'Confirm',
                );

                if (!confirmed) return;

                showLoader(context);

                try {
                  await _service.takeWork(event.eventId, userId);

                  hideLoader(context);

                  await showSuccessAlert(
                    context: context,
                    title: 'Success',
                    message: 'Work confirmed successfully',
                  );

                } catch (e) {
                  hideLoader(context);
                  NotificationSnack.showError(e.toString());

                }
              },

              child: WorkCard(
                date: formatDate(event.eventDateTs),
                time: formatTime(event.eventDateTs),
                title: event.eventName,
                code: getInitials(event.eventName),
                status: 'Available',
              ),
            );
          },
        );
      }
    );
  }
}

class ConfirmedWorksTab extends StatelessWidget {
  final String userId;
   ConfirmedWorksTab({super.key,required this.userId});
  final EventService _service = EventService();
  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: _service.fetchConfirmedWorks(userId),
        builder: (context4, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return  Center(child: Text('No confirmed events found',style: AppTypography.body2,));
          }
        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          itemBuilder: (context7,index){

            final event = events[index];
            return  InkWell(
              onTap: (){
                callNext(WorkDetailsScreen(work:event ,), context);


              },
              child: WorkCard(
                date: formatDate(event.eventDateTs),
                time: formatTime(event.eventDateTs),
                title: event.eventName,
                code: getInitials(event.eventName),
                status: 'confirmed',
              ),
            );
          },
        );
      }
    );
  }
}
