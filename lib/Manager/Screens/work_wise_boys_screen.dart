import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Providers/EventDetailProvider.dart';

class EventAllBoys extends StatelessWidget {
  final String eventId;

  const EventAllBoys({super.key, required this.eventId});

  // 📞 CALL
  void _callNumber(String phone) async {
    final Uri url = Uri(scheme: "tel", path: phone);
    await launchUrl(url);
  }

  // 💬 WHATSAPP MESSAGE
  void _openWhatsApp(String phone) async {
    final Uri url = Uri.parse("https://wa.me/$phone");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Confirmed Boys'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.confirmedBoysList.isEmpty) {
            return const Center(child: Text('No boys assigned'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.confirmedBoysList.length,
            itemBuilder: (context, index) {
              final boy = provider.confirmedBoysList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // Avatar
                    const CircleAvatar(
                      radius: 26,
                      child: Icon(Icons.person, size: 28),
                    ),

                    const SizedBox(width: 12),

                    // Name + Phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boy.boyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            boy.boyPhone,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ACTION BUTTONS
                    Row(
                      children: [
                        // 📞 Call
                        IconButton(
                          onPressed: () => _callNumber(boy.boyPhone),
                          icon: const Icon(Icons.call, color: Colors.green),
                        ),

                        // 💬 WhatsApp
                        IconButton(
                          onPressed: () => _openWhatsApp(boy.boyPhone),
                          icon:  Image.asset('assets/whsp.png', color: Colors.teal,
                          scale: 8,),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
