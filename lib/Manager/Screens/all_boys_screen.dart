import 'package:cateryyx/Constants/my_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Boys/Providers/boys_provider.dart';
import '../../core/utils/url_launcher.dart';
import 'BoyDetailsScreen.dart';

class BoysListScreen extends StatelessWidget {
  const BoysListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xff1A237E);
    const primaryOrange = Color(0xffE65100);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "My Boys",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add, color: primaryOrange),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: primaryOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryOrange,
            tabs: [
              Tab(text: "Active Boys"),
              Tab(text: "Blocked Boys"),
            ],
          ),
        ),
        body: Consumer<BoysProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingBoys) {
              return const Center(child: CircularProgressIndicator());
            }

            final activeBoys = provider.filterBoysList
                .where((b) => b['BLOCK_STATUS'] != "BLOCKED")
                .toList();

            final blockedBoys = provider.filterBoysList
                .where((b) => b['BLOCK_STATUS'] == "BLOCKED")
                .toList();

            return Column(
              children: [
                _searchBar(provider),

                Expanded(
                  child: TabBarView(
                    children: [
                      /// ACTIVE BOYS TAB
                      _boysList(
                        context,
                        activeBoys,
                      ),

                      /// BLOCKED BOYS TAB
                      _boysList(
                        context,
                        blockedBoys,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🔍 Search Bar
  Widget _searchBar(BoysProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: TextField(
        onChanged: provider.searchBoys,
        decoration: InputDecoration(
          hintText: "Search by name or phone",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// ⭐ UNIVERSAL LIST BUILDER (No Block/Unblock)
  Widget _boysList(BuildContext context, List<Map<String, dynamic>> boysList) {
    if (boysList.isEmpty) return _emptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: boysList.length,
      itemBuilder: (context, index) {
        final boy = boysList[index];
        return InkWell(
          onTap: () => callNext(BoyDetailsScreen(boy: boy), context),
          child: _boyCard(
            context,
            boy,
          ),
        );
      },
    );
  }

  /// 👤 Boy Card (Only info + call + WhatsApp)
  Widget _boyCard(BuildContext context, Map<String, dynamic> boy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 👤 Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xff1A237E).withOpacity(0.1),
            child: const Icon(Icons.person, size: 30, color: Color(0xff1A237E)),
          ),

          const SizedBox(width: 14),

          /// 📄 Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(boy['NAME'] ?? '',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(boy['PHONE'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text("${boy['PLACE'] ?? ''}, ${boy['DISTRICT'] ?? ''}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// ☎️ CALL / WHATSAPP ONLY
          Row(
            children: [
              IconButton(
                onPressed: () => callNumber(boy['PHONE']),
                icon: const Icon(Icons.call, color: Colors.blue),
              ),
              IconButton(
                onPressed: () => openWhatsApp(boy['PHONE']),
                icon: Image.asset(
                  'assets/whsp.png',
                  color: Colors.green,
                  scale: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📭 Empty State UI
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text("No data", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
