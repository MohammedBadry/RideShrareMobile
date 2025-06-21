import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DriversScreen extends StatefulWidget {
  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> availableDrivers = [];
  List<Map<String, dynamic>> optimizedDrivers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadDrivers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadDrivers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final available = await ApiService.getAvailableDrivers();
      final optimized = await ApiService.getOptimizedDrivers();
      
      setState(() {
        availableDrivers = available;
        optimizedDrivers = optimized;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drivers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Available Drivers'),
            Tab(text: 'Optimized Drivers'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadDrivers,
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
                        onPressed: loadDrivers,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDriversList(availableDrivers, 'No available drivers'),
                    _buildDriversList(optimizedDrivers, 'No optimized drivers'),
                  ],
                ),
    );
  }

  Widget _buildDriversList(List<Map<String, dynamic>> drivers, String emptyMessage) {
    if (drivers.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return RefreshIndicator(
      onRefresh: loadDrivers,
      child: ListView.builder(
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(driver['name']?[0]?.toUpperCase() ?? 'D'),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              title: Text(driver['name'] ?? 'Unknown Driver'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${driver['phone'] ?? 'N/A'}'),
                  Text('Status: ${driver['status'] ?? 'Unknown'}'),
                  Text('Vehicle: ${driver['vehicle']?['model'] ?? 'Not assigned'}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'details') {
                    showDriverDetails(driver);
                  } else if (value == 'active_trips') {
                    showDriverActiveTrips(driver['id']);
                  } else if (value == 'available_jobs') {
                    showAvailableJobs(driver['id']);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'details',
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: 'active_trips',
                    child: Text('Active Trips'),
                  ),
                  PopupMenuItem(
                    value: 'available_jobs',
                    child: Text('Available Jobs'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showDriverDetails(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Driver Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${driver['id']}'),
              Text('Name: ${driver['name'] ?? 'N/A'}'),
              Text('Email: ${driver['email'] ?? 'N/A'}'),
              Text('Phone: ${driver['phone'] ?? 'N/A'}'),
              Text('Status: ${driver['status'] ?? 'N/A'}'),
              Text('License: ${driver['license_number'] ?? 'N/A'}'),
              Text('Vehicle: ${driver['vehicle']?['model'] ?? 'Not assigned'}'),
              Text('Created: ${driver['created_at'] ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void showDriverActiveTrips(int driverId) async {
    try {
      final trips = await ApiService.getDriverActiveTrips(driverId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Active Trips'),
          content: Container(
            width: double.maxFinite,
            child: trips.isEmpty
                ? Text('No active trips')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return ListTile(
                        title: Text('Trip #${trip['id']}'),
                        subtitle: Text('Status: ${trip['status']}'),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load active trips: ${e.toString()}')),
      );
    }
  }

  void showAvailableJobs(int driverId) async {
    try {
      final jobs = await ApiService.getAvailableJobs(driverId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Available Jobs'),
          content: Container(
            width: double.maxFinite,
            child: jobs.isEmpty
                ? Text('No available jobs')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return ListTile(
                        title: Text('Trip #${job['id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup: ${job['pickup_location']}'),
                            Text('Dropoff: ${job['dropoff_location']}'),
                            Text('Fare: \$${job['fare']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => acceptJob(driverId, job['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => rejectJob(driverId, job['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load available jobs: ${e.toString()}')),
      );
    }
  }

  Future<void> acceptJob(int driverId, int tripId) async {
    try {
      await ApiService.acceptJob(driverId, tripId);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job accepted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept job: ${e.toString()}')),
      );
    }
  }

  Future<void> rejectJob(int driverId, int tripId) async {
    try {
      await ApiService.rejectJob(driverId, tripId);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject job: ${e.toString()}')),
      );
    }
  }
} 