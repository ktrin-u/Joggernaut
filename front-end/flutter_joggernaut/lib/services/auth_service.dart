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

  Future createUser(firstname, lastname, email, phonenumber, password) async {
    var uri = Uri.parse(registerURL);
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        }, 
        body: {
          "firstname": firstname,
          "lastname": lastname,
          "email" : email,
          "phonenumber" : phonenumber,
          "password" : password,
        },
        encoding: Encoding.getByName('utf-8')
      );
      return response;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future forgetPasswordPost(email) async {
    if (email == "getsavedemail"){
      email = await storage.getData("email");
    }
    var uri = Uri.parse(forgetPasswordURL);
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        }, 
        body: {
          "email": email        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Forget Password request posted successfully!");
        await storage.saveData("email", email);
        return response;
      } else {
        print("Failed to request forget password. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future forgetPasswordGet(token) async {
    var uri = Uri.parse(forgetPasswordURL).replace(queryParameters: {
      "email": await storage.getData("email"),
      "token": token
    });
    try {
      var response = await client.get(
        uri,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        print("Verification code and email are correct");
        await storage.saveData("verification_code", token);
        return response;
      } else {
        print("Incorrect verification code or email. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future forgetPasswordChange(newPassword, confirmPassword) async {
    var uri = Uri.parse(forgetPasswordChangeURL);
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",  
          "email": (await storage.getData("email")).toString(),
          "token": (await storage.getData("verification_code")).toString()
        }, 
        body: {
          "new_password": newPassword,
          "confirm_password": confirmPassword
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Changed password-forget successfully!");
        return response;
      } else {
        print("Failed to change password-forget. Status code: ${response.body}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
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