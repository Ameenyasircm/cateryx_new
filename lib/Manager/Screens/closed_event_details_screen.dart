
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/colors.dart';
import '../../core/theme/app_spacing.dart';
import '../Providers/EventDetailProvider.dart';
import '../widgets/event_details_widgets.dart';

class ClosedEventDetailsScreen extends StatelessWidget {
  const ClosedEventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor:blue7E,
        title:  Text('Completed Events Details',style: AppTypography.body1.copyWith(
          color: Colors.white
        ),),
      ),
      body: Consumer<EventDetailsProvider>(
          builder: (contexts,provider,child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              
                  /// Event Location
                  sectionTitle('Event Location'),
                  detailCard(children: [
                    detailRow('Location', provider.closedEventModel!.locationName),
                    divider(),
                    detailRow('Meal Type', provider.closedEventModel!.mealType),
                    divider(),
                    detailRow('Event Date', provider.closedEventModel!.eventDate),
                  ]),
              
                  AppSpacing.h20,
              
                  /// Google Map
                  sectionTitle('Google Map Location'),
                  mapBox(provider.closedEventModel!.latitude, provider.closedEventModel!.longitude,context),
              
                  AppSpacing.h20,
              
                  /// Event Details
                  sectionTitle(''
                      'Event Details'),
                  detailCard(children: [
                    detailRow('Description', provider.closedEventModel!.description),
                    divider(),
                    detailRow('Boys Required', provider.closedEventModel!.boysRequired.toString()),
                    divider(),
                    detailRow('Status', 'Closed'),
                  ]),
              
                  AppSpacing.h20,
              
              
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
