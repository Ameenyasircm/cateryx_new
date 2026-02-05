import 'package:cateryyx/Manager/Providers/ManagerProvider.dart';
import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/colors.dart';
import '../../core/theme/app_typography.dart';

class ManagerPaymentReportScreen extends StatelessWidget {
  final String fromWhere;
  final String? boyId;
  const ManagerPaymentReportScreen({super.key,required this.fromWhere,this.boyId});

  @override
  Widget build(BuildContext context) {
    print('$fromWhere Frommm');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor:blue7E,
        title:  Text('Payment Report',style: AppTypography.body1.copyWith(
            color: Colors.white
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,color: Colors.white,),
            onPressed: () {
              context.read<ManagerProvider>().clearFilters();
            },
          ),
        ],
      ),

      body: Consumer<ManagerProvider>(
        builder: (context2, pro, child) {
          if (pro.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pro.reportList.isEmpty) {
            return const Center(child: Text("No payments found"));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              // ✅ load next page when scroll bottom
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 100) {
                pro.fetchMore(boyId:fromWhere == 'boy' ?boyId : null);
              }
              return false;
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    children: [
                      // ✅ Search
                      Visibility(visible: fromWhere!='boy',
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: "Search Boy Name / Phone",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            // ✅ debounce effect (optional)
                            pro.applyLocalSearch(val);
                          },
                        ),
                      ),

                      AppSpacing.h10,

                      // ✅ Date range row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );

                                if (picked != null) {
                                  pro.setDateRange(from:picked.start,to:picked.end );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  pro.fromDate == null
                                      ? "Select Date Range"
                                      : "${pro.fromDate!.day}/${pro.fromDate!.month}/${pro.fromDate!.year}  -  "
                                      "${pro.toDate!.day}/${pro.toDate!.month}/${pro.toDate!.year}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              pro.clearFilters();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Builder(
                      builder: (context) {
                        // ✅ ADD HERE
                        const TextStyle headerStyle =
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold);

                        const TextStyle rowStyle =
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              border: TableBorder.all(width: 1),
                              headingRowColor:
                              MaterialStateProperty.all(Colors.grey.shade200),

                              columns: [
                                DataColumn(label: Text("Sl.No", style: headerStyle)),
                                DataColumn(label: Text("Event Date", style: headerStyle)),
                                DataColumn(label: Text("Event", style: headerStyle)),
                                DataColumn(label: Text("Amount", style: headerStyle)),
                                DataColumn(label: Text("Location", style: headerStyle)),
                                DataColumn(label: Text("Payment Date", style: headerStyle)),
                                if (fromWhere != "boy")
                                DataColumn(label: Text("Boy Name", style: headerStyle)),
                                if (fromWhere != "boy")
                                DataColumn(label: Text("Boy Phone", style: headerStyle)),

                              ],
                              rows: pro.reportList.asMap().entries.map((entry) {
                                final int index = entry.key;       // ✅ row index
                                final m = entry.value;
                                return DataRow(
                                  cells: [
                                    DataCell(Text("${index + 1}", style: rowStyle)),
                                    DataCell(Text(m.eventDate, style: rowStyle)),
                                    DataCell(Text(m.eventName, style: rowStyle)),
                                    DataCell(Text(m.paymentAmount.toString(), style: rowStyle)),
                                    DataCell(Text(m.locationName, style: rowStyle)),
                                    DataCell(Text(pro.formatDateTime(m.paymentUpdatedAt),
                                        style: rowStyle)),
                                    if (fromWhere != "boy")
                                    DataCell(Text(m.boyName, style: rowStyle)),
                                    if (fromWhere != "boy")
                                    DataCell(Text(m.boyPhone, style: rowStyle)),

                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),

                  ),
                ),


                // ✅ show loading bar at bottom when fetching more
                if (pro.loadingMore)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
