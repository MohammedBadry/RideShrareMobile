import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Trip Management
  static Future<List<Map<String, dynamic>>> getTrips() async {
    final response = await http.get(Uri.parse('$baseUrl/api/trips'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load trips');
  }

  static Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/trips'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tripData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create trip');
  }

  static Future<Map<String, dynamic>> getTripDetails(int tripId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/trips/$tripId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load trip details');
  }

  static Future<List<Map<String, dynamic>>> getUserHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/api/trips/user-history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load user history');
  }

  static Future<List<Map<String, dynamic>>> getDriverActiveTrips(int driverId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/trips/driver/$driverId/active'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load driver active trips');
  }

  static Future<Map<String, dynamic>> updateTripStatus(int tripId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/trips/$tripId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update trip status');
  }

  // Job Notifications (Driver Features)
  static Future<List<Map<String, dynamic>>> getAvailableJobs(int driverId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/jobs/driver/$driverId/available'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load available jobs');
  }

  static Future<Map<String, dynamic>> acceptJob(int driverId, int tripId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/jobs/driver/$driverId/accept'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'trip_id': tripId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to accept job');
  }

  static Future<Map<String, dynamic>> rejectJob(int driverId, int tripId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/jobs/driver/$driverId/reject/$tripId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to reject job');
  }

  static Future<Map<String, dynamic>> getCurrentJob(int driverId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/jobs/driver/$driverId/current'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load current job');
  }

  static Future<Map<String, dynamic>> completeJob(int driverId, int tripId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/jobs/driver/$driverId/complete/$tripId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to complete job');
  }

  // Available Drivers
  static Future<List<Map<String, dynamic>>> getAvailableDrivers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/available-drivers'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load available drivers');
  }

  static Future<List<Map<String, dynamic>>> getOptimizedDrivers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/available-drivers/optimized'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load optimized drivers');
  }

  // Vehicle Location
  static Future<Map<String, dynamic>> updateVehicleLocation(int vehicleId, double latitude, double longitude) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/vehicles/$vehicleId/location'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update vehicle location');
  }

  static Future<Map<String, dynamic>> getVehicleLocation(int vehicleId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/vehicles/$vehicleId/location'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load vehicle location');
  }
} 