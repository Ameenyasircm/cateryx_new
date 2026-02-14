import 'package:cateryyx/Constants/my_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/ManagerProvider.dart';
import 'BoyDetailsScreen.dart';

class BoysStatusScreen extends StatefulWidget {
  const BoysStatusScreen({super.key});

  @override
  State<BoysStatusScreen> createState() => _BoysStatusScreenState();
}

class _BoysStatusScreenState extends State<BoysStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().fetchBoysByStatus();
    });
  }

  static const primaryBlue = Color(0xff1A237E);
  static const primaryOrange = Color(0xffE65100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Boys Status",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingBoysByStatus) {
            return const Center(child: CircularProgressIndicator());
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: primaryBlue,
                  child: const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 18),
                            SizedBox(width: 8),
                            Text("Approved"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel, size: 18),
                            SizedBox(width: 8),
                            Text("Rejected"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Approved Boys List
                      _buildBoysList(
                        provider.approvedBoysList,
                        "No approved boys found",
                        Colors.green,
                      ),
                      // Rejected Boys List
                      _buildBoysList(
                        provider.rejectedBoysList,
                        "No rejected boys found",
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoysList(List<Map<String, dynamic>> boysList, String emptyMessage, Color statusColor) {
    if (boysList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ManagerProvider>().fetchBoysByStatus();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boysList.length,
        itemBuilder: (context, index) {
          final boy = boysList[index];
          return _buildBoyTile(boy, statusColor);
        },
      ),
    );
  }

  Widget _buildBoyTile(Map<String, dynamic> boy, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primaryBlue.withOpacity(0.1),
          backgroundImage: boy['BOY_PHOTO_URL'] != null
              ? NetworkImage(boy['BOY_PHOTO_URL'])
              : null,
          child: boy['BOY_PHOTO_URL'] == null
              ? const Icon(Icons.person, color: primaryBlue, size: 28)
              : null,
        ),
        title: Text(
          boy['NAME'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Phone: ${boy['PHONE'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                boy['STATUS'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          callNext(
            BoyDetailsScreen(boy: boy),
            context,
          );
        },
      ),
    );
  }
}
