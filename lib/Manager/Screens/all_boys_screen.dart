import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Boys/Providers/boys_provider.dart';

class BoysListScreen extends StatelessWidget {
  const BoysListScreen({Key? key}) : super(key: key);

  @override

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xff1A237E);
    const primaryOrange = Color(0xffE65100);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Registered Boys",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: primaryOrange),
            onPressed: () {
              // Navigate to Register Boy Screen
            },
          ),
        ],
      ),
      body: Consumer<BoysProvider>(
        builder: (context, provider, _) {

          /// 🔄 Loading State
          if (provider.isLoadingBoys) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 📭 Empty State
          if (provider.filterBoysList.isEmpty) {
            return _emptyState();
          }

          return Column(
            children: [
              _searchBar(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.filterBoysList.length,
                  itemBuilder: (context, index) {
                    final boy = provider.filterBoysList[index];
                    return _boyCard(boy);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔍 Search Bar
  Widget _searchBar(BoysProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: TextField(
        onChanged: provider.filterBoys,
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

  /// 👤 Boy Card
  Widget _boyCard(Map<String, dynamic> boy) {
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
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xff1A237E).withOpacity(0.1),
            child: const Icon(Icons.person, size: 30, color: Color(0xff1A237E)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boy['NAME'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  boy['PHONE'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${boy['PLACE'] ?? ''}, ${boy['DISTRICT'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  /// 📭 Empty State UI
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.group_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No boys registered yet",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
