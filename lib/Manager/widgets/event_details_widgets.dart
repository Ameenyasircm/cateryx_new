import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../Providers/EventDetailProvider.dart';

Widget infoTile({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: cardDecoration(),
    child: Row(
      children: [
        Icon(icon, color: clWhite),
        AppSpacing.w10,
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body2.copyWith(color: clWhite),
          ),
        ),
      ],
    ),
  );
}

Widget mapBox(double lat, double lng,BuildContext context) {
  EventDetailsProvider eventDetailsProvider = Provider.of<EventDetailsProvider>(context);
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: cardDecoration(color: Colors.grey.shade300),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lat == 0 && lng == 0
                    ? 'Location not available'
                    : 'Lat: $lat , Lng: $lng',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.blue),
          ],
        ),
        AppSpacing.h10,
        OutlinedButton.icon(
          onPressed: lat == 0 && lng == 0 ? null : () {
            eventDetailsProvider.openGoogleMap(lat, lng);
          },
          icon: const Icon(Icons.location_on_outlined, color: Colors.blueAccent),
          label: Text(
            'Open Google Map',
            style: AppTypography.body1.copyWith(color: Colors.blueAccent),
          ),
        ),
      ],
    ),
  );
}

Divider divider() => const Divider(thickness: 0.4);

BoxDecoration cardDecoration({Color color = Colors.white12}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 5,
      ),
    ],
  );
}


Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

Widget detailCard({required List<Widget> children}) {
  return Container(
    decoration: cardDecoration(color: Colors.grey.shade300),
    child: Column(children: children),
  );
}

Widget detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: Colors.black45),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.caption,
          ),
        ),
      ],
    ),
  );
}