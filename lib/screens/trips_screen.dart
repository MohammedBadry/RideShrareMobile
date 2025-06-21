import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadTrips();
  }

  Future<void> loadTrips() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final tripsData = await ApiService.getTrips();
      setState(() {
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

  Future<void> createTrip() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateTripDialog(),
    );
    
    if (result != null) {
      try {
        await ApiService.createTrip(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip created successfully!')),
        );
        loadTrips();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create trip: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> updateTripStatus(int tripId, String currentStatus) async {
    String newStatus = currentStatus;
    if (currentStatus == 'pending') newStatus = 'assigned';
    else if (currentStatus == 'assigned') newStatus = 'in_progress';
    else if (currentStatus == 'in_progress') newStatus = 'completed';

    try {
      await ApiService.updateTripStatus(tripId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip status updated!')),
      );
      loadTrips();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trips'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadTrips,
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
                        onPressed: loadTrips,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : trips.isEmpty
                  ? Center(child: Text('No trips found'))
                  : RefreshIndicator(
                      onRefresh: loadTrips,
                      child: ListView.builder(
                        itemCount: trips.length,
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('Trip #${trip['id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${trip['status']}'),
                                  Text('User: ${trip['user']?['name'] ?? 'N/A'}'),
                                  Text('Driver: ${trip['driver']?['name'] ?? 'Not assigned'}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'details') {
                                    showTripDetails(trip);
                                  } else if (value == 'update_status') {
                                    updateTripStatus(trip['id'], trip['status']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'details',
                                    child: Text('View Details'),
                                  ),
                                  PopupMenuItem(
                                    value: 'update_status',
                                    child: Text('Update Status'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: createTrip,
        child: Icon(Icons.add),
        tooltip: 'Create New Trip',
      ),
    );
  }

  void showTripDetails(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trip Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${trip['id']}'),
              Text('Status: ${trip['status']}'),
              Text('User: ${trip['user']?['name'] ?? 'N/A'}'),
              Text('Driver: ${trip['driver']?['name'] ?? 'Not assigned'}'),
              Text('Vehicle: ${trip['vehicle']?['model'] ?? 'N/A'}'),
              Text('Pickup: ${trip['pickup_location'] ?? 'N/A'}'),
              Text('Dropoff: ${trip['dropoff_location'] ?? 'N/A'}'),
              Text('Fare: \$${trip['fare'] ?? 'N/A'}'),
              Text('Created: ${trip['created_at'] ?? 'N/A'}'),
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

class CreateTripDialog extends StatefulWidget {
  @override
  _CreateTripDialogState createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<CreateTripDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _fareController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New Trip'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _pickupController,
              decoration: InputDecoration(labelText: 'Pickup Location'),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            TextFormField(
              controller: _dropoffController,
              decoration: InputDecoration(labelText: 'Dropoff Location'),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            TextFormField(
              controller: _fareController,
              decoration: InputDecoration(labelText: 'Fare'),
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
                'pickup_location': _pickupController.text,
                'dropoff_location': _dropoffController.text,
                'fare': double.tryParse(_fareController.text) ?? 0.0,
                'user_id': 1, // TODO: Get from authentication
              });
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
} 