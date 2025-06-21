import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> userHistory = [];
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadAnalytics() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final history = await ApiService.getUserHistory();
      final tripsData = await ApiService.getTrips();
      
      setState(() {
        userHistory = history;
        trips = tripsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Map<String, int> getTripStatusStats() {
    Map<String, int> stats = {};
    for (var trip in trips) {
      String status = trip['status'] ?? 'unknown';
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  double getTotalRevenue() {
    return trips.fold(0.0, (sum, trip) => sum + (trip['fare'] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Trip History'),
            Tab(text: 'Statistics'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadAnalytics,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      ElevatedButton(
                        onPressed: loadAnalytics,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTripHistoryTab(),
                    _buildStatisticsTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    final statusStats = getTripStatusStats();
    final totalRevenue = getTotalRevenue();
    
    return RefreshIndicator(
      onRefresh: loadAnalytics,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard('Total Trips', trips.length.toString(), Icons.directions_car),
            SizedBox(height: 16),
            _buildStatCard('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.attach_money),
            SizedBox(height: 16),
            _buildStatCard('User History', userHistory.length.toString(), Icons.history),
            SizedBox(height: 16),
            Text(
              'Trip Status Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...statusStats.entries.map((entry) => _buildStatusCard(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHistoryTab() {
    return RefreshIndicator(
      onRefresh: loadAnalytics,
      child: userHistory.isEmpty
          ? Center(child: Text('No trip history found'))
          : ListView.builder(
              itemCount: userHistory.length,
              itemBuilder: (context, index) {
                final trip = userHistory[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Trip #${trip['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${trip['status']}'),
                        Text('Fare: \$${trip['fare'] ?? 'N/A'}'),
                        Text('Date: ${trip['created_at'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: Icon(
                      _getStatusIcon(trip['status']),
                      color: _getStatusColor(trip['status']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatisticsTab() {
    final statusStats = getTripStatusStats();
    final totalTrips = trips.length;
    
    return RefreshIndicator(
      onRefresh: loadAnalytics,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...statusStats.entries.map((entry) {
              final percentage = totalTrips > 0 ? (entry.value / totalTrips * 100) : 0.0;
              return _buildStatisticCard(
                entry.key.toUpperCase(),
                '${entry.value} trips (${percentage.toStringAsFixed(1)}%)',
                _getStatusColor(entry.key),
              );
            }),
            SizedBox(height: 16),
            Text(
              'Revenue Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildStatisticCard(
              'Total Revenue',
              '\$${getTotalRevenue().toStringAsFixed(2)}',
              Colors.green,
            ),
            SizedBox(height: 16),
            _buildStatisticCard(
              'Average Fare',
              totalTrips > 0 ? '\$${(getTotalRevenue() / totalTrips).toStringAsFixed(2)}' : '\$0.00',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.indigo),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, int count) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getStatusIcon(status),
          color: _getStatusColor(status),
        ),
        title: Text(status.toUpperCase()),
        trailing: Text(
          count.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'assigned':
        return Icons.person_add;
      case 'in_progress':
        return Icons.directions_car;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 