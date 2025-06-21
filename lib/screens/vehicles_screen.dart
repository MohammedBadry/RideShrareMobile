import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VehiclesScreen extends StatefulWidget {
  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      // For now, we'll create mock vehicle data since the API doesn't have a get all vehicles endpoint
      // In a real app, you'd call ApiService.getVehicles()
      setState(() {
        vehicles = [
          {
            'id': 1,
            'model': 'Toyota Camry',
            'plate_number': 'ABC123',
            'status': 'available',
            'driver': {'name': 'John Doe'},
            'latitude': 40.7128,
            'longitude': -74.0060,
          },
          {
            'id': 2,
            'model': 'Honda Civic',
            'plate_number': 'XYZ789',
            'status': 'in_use',
            'driver': {'name': 'Jane Smith'},
            'latitude': 40.7589,
            'longitude': -73.9851,
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> updateVehicleLocation(int vehicleId) async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => UpdateLocationDialog(),
    );
    
    if (result != null) {
      try {
        await ApiService.updateVehicleLocation(
          vehicleId,
          result['latitude']!,
          result['longitude']!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle location updated!')),
        );
        loadVehicles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> getVehicleLocation(int vehicleId) async {
    try {
      final location = await ApiService.getVehicleLocation(vehicleId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Vehicle Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Latitude: ${location['latitude']}'),
              Text('Longitude: ${location['longitude']}'),
              Text('Updated: ${location['updated_at'] ?? 'N/A'}'),
            ],
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
        SnackBar(content: Text('Failed to get location: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicles'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadVehicles,
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
                        onPressed: loadVehicles,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : vehicles.isEmpty
                  ? Center(child: Text('No vehicles found'))
                  : RefreshIndicator(
                      onRefresh: loadVehicles,
                      child: ListView.builder(
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.local_taxi),
                                backgroundColor: _getStatusColor(vehicle['status']),
                                foregroundColor: Colors.white,
                              ),
                              title: Text(vehicle['model'] ?? 'Unknown Vehicle'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Plate: ${vehicle['plate_number'] ?? 'N/A'}'),
                                  Text('Status: ${vehicle['status'] ?? 'Unknown'}'),
                                  Text('Driver: ${vehicle['driver']?['name'] ?? 'Not assigned'}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'details') {
                                    showVehicleDetails(vehicle);
                                  } else if (value == 'update_location') {
                                    updateVehicleLocation(vehicle['id']);
                                  } else if (value == 'get_location') {
                                    getVehicleLocation(vehicle['id']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'details',
                                    child: Text('View Details'),
                                  ),
                                  PopupMenuItem(
                                    value: 'update_location',
                                    child: Text('Update Location'),
                                  ),
                                  PopupMenuItem(
                                    value: 'get_location',
                                    child: Text('Get Location'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'in_use':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void showVehicleDetails(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vehicle Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${vehicle['id']}'),
              Text('Model: ${vehicle['model'] ?? 'N/A'}'),
              Text('Plate Number: ${vehicle['plate_number'] ?? 'N/A'}'),
              Text('Status: ${vehicle['status'] ?? 'N/A'}'),
              Text('Driver: ${vehicle['driver']?['name'] ?? 'Not assigned'}'),
              Text('Latitude: ${vehicle['latitude'] ?? 'N/A'}'),
              Text('Longitude: ${vehicle['longitude'] ?? 'N/A'}'),
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
}

class UpdateLocationDialog extends StatefulWidget {
  @override
  _UpdateLocationDialogState createState() => _UpdateLocationDialogState();
}

class _UpdateLocationDialogState extends State<UpdateLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Vehicle Location'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            TextFormField(
              controller: _longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.pop(context, {
                'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
                'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
              });
            }
          },
          child: Text('Update'),
        ),
      ],
    );
  }
} 