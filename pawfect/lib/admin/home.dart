import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pawfect/admin/appbar.dart';
import 'package:pawfect/admin/drawer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int usersCount = 0;
  int vetsCount = 0;
  int productsCount = 0;
  List<FlSpot> visitSpots = [];

  @override
  void initState() {
    super.initState();
    fetchCounts();
    fetchVisits();
  }

  Future<void> fetchCounts() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final vetsSnapshot =
          await FirebaseFirestore.instance.collection('veterinarians').get();
      final productsSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        usersCount = usersSnapshot.docs.length;
        vetsCount = vetsSnapshot.docs.length;
        productsCount = productsSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint("Error fetching counts: $e");
    }
  }

  Future<void> fetchVisits() async {
    try {
      DateTime today = DateTime.now();
      DateFormat formatter = DateFormat('yyyy-MM-dd');

      List<FlSpot> spots = [];
      for (int i = 0; i < 7; i++) {
        DateTime day = today.subtract(Duration(days: 6 - i));
        String dateKey = formatter.format(day);

        final snapshot = await FirebaseFirestore.instance
            .collection('visits')
            .doc(dateKey)
            .get();

        int count = 0;
        if (snapshot.exists && snapshot.data() != null) {
          count = snapshot.data()?['count'] ?? 0;
        }

        spots.add(FlSpot((i + 1).toDouble(), count.toDouble()));
      }

      setState(() {
        visitSpots = spots;
      });
    } catch (e) {
      debugPrint("Error fetching visits: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: "Admin Dashboard"),
      drawer: const AdminDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6DD5FA), Color(0xFFFFFFFF), Color(0xFF2980B9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top cards row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    context,
                    "Users",
                    usersCount.toString(),
                    Icons.people,
                    Colors.blueAccent,
                    "/users",
                  ),
                  _buildStatCard(
                    context,
                    "Veterinarians",
                    vetsCount.toString(),
                    Icons.medical_services,
                    Colors.greenAccent,
                    "/vets",
                  ),
                  _buildStatCard(
                    context,
                    "Products",
                    productsCount.toString(),
                    Icons.shopping_bag,
                    Colors.deepPurpleAccent,
                    "/products",
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Chart
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: visitSpots.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : LineChart(
                            LineChartData(
                              minX: 1,
                              maxX: 7,
                              minY: 0,
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  spots: visitSpots,
                                  color: Colors.indigoAccent,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 1:
                                          return const Text("Mon");
                                        case 2:
                                          return const Text("Tue");
                                        case 3:
                                          return const Text("Wed");
                                        case 4:
                                          return const Text("Thu");
                                        case 5:
                                          return const Text("Fri");
                                        case 6:
                                          return const Text("Sat");
                                        case 7:
                                          return const Text("Sun");
                                      }
                                      return const Text("");
                                    },
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count,
      IconData icon, Color color, String route) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 10),
                Text(count,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
