import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class IPAddressService {
  static Future<String?> getUserIPAddress() async {
    try {
      // Try multiple IP detection services for reliability
      List<String> ipServices = [
        'https://api.ipify.org?format=json',
        'https://ipapi.co/json/',
        'https://httpbin.org/ip',
      ];

      for (String serviceUrl in ipServices) {
        try {
          final response = await http.get(
            Uri.parse(serviceUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            String? ipAddress;

            // Parse based on different API responses
            if (serviceUrl.contains('ipify')) {
              ipAddress = data['ip'];
            } else if (serviceUrl.contains('ipapi')) {
              ipAddress = data['ip'];
            } else if (serviceUrl.contains('httpbin')) {
              ipAddress = data['origin'];
            }

            if (ipAddress != null && ipAddress.isNotEmpty) {
              print('IP Address obtained from $serviceUrl: $ipAddress');
              return ipAddress;
            }
          }
        } catch (e) {
          print('Error with $serviceUrl: $e');
          continue; // Try next service
        }
      }

      // If all services fail, return a default or null
      return null;
    } catch (e) {
      print('Error getting IP address: $e');
      return null;
    }
  }

  // Alternative method using a different approach
  static Future<String?> getIPAddressAlternative() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipgeolocation.io/ipgeo?apiKey=free'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'];
      }
    } catch (e) {
      print('Alternative IP service error: $e');
    }
    return null;
  }

  // Get IP with fallback
  static Future<String> getIPAddressWithFallback() async {
    String? ip = await getUserIPAddress();

    if (ip == null || ip.isEmpty) {
      ip = await getIPAddressAlternative();
    }

    // Return IP or unknown if all methods fail
    return ip ?? 'Unknown';
  }
}