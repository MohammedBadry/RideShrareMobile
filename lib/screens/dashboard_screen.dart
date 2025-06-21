import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import 'trips_screen.dart';
import 'drivers_screen.dart';
import 'vehicles_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          children: [
            _DashboardCard(
              icon: Icons.directions_car,
              label: 'Trips',
              color: Colors.indigo,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripsScreen())),
            ),
            _DashboardCard(
              icon: Icons.person,
              label: 'Drivers',
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriversScreen())),
            ),
            _DashboardCard(
              icon: Icons.local_taxi,
              label: 'Vehicles',
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VehiclesScreen())),
            ),
            _DashboardCard(
              icon: Icons.analytics,
              label: 'Analytics',
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen())),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 0),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 12),
              Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
} 