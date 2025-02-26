// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';

class AuthService {
  var client = http.Client();
  final String clientId = "QT0aBroxFucr1xUwFIjgwI69IQRH97WPUVOtz11X";
  final String clientSecret = "GA4lv1y9qbxMyz8IwiPr0CkqQBdovRbDhMHIj77obQuPX895z7lzU8PVbpLe7sgpi4VO6ejETH7BSxLSVNS591LQOGBR0UTPo7B8vsbOoH5XWvTIFnMChy0c0vq68nOY";
  final SecureStorageService storage = SecureStorageService();

  Future login(String username, String password) async {
    try {
      var response = await client.post(
        Uri.parse(loginURL),
        headers: {
          "Content-Type":  "application/x-www-form-urlencoded", 
        },
        body:{ 
          "username" : username,
          "password" : password,
          "grant_type" :"password",
          "Scope" : "[]",
          "client_id" : clientId
        },
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        await storage.saveToken( "access_token", data["access_token"]);
        await storage.saveToken( "refresh_token", data["refresh_token"]);
        // ignore: unused_local_variable
        var userInfo = await ApiService().getUserInfo();
        return response;
      } else {
        print("Login failed: ${response.body}");
        return response;
      }
    } catch (e) {
      print("Error logging in: $e");
    }
  }

  Future logout() async {
    try {
      var response = await client.post(
        Uri.parse(logoutURL),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded", 
        },
        body:{ 
          "token": await storage.getAccessToken(),
          "client_id" : clientId
        },
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        print("Logged out succesfully!");
      } else {
        print("Logout failed: ${response.body}");
      }
    } catch (e) {
      print("Error logging out: $e");
    }
    await storage.deleteToken("access_token");
    await storage.deleteToken("refresh_token");
    await storage.clearAll();
  }

  Future getAccessToken() async {
    return await storage.getAccessToken();
  }

  Future getRefreshToken() async {
    return await storage.getAccessToken();
  }

  Future clearAll() async {
    return await storage.clearAll();
  }
}