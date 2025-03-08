// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';

class ApiService {
  var client = http.Client();
  final SecureStorageService storage = SecureStorageService();

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

  Future deleteAccount() async {
    var uri = Uri.parse(deleteAccURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded", 
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body:{
          "delete": "1",
          "confirm_delete": "1"
        },
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        print("Account deleted succesfully!");
        return response;
      } else {
        print("Account deletion failed: ${response.body}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getUserInfo() async {
    var uri = Uri.parse(getUserInfoURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        var userInfo = jsonDecode(response.body);
        if (await storage.getData("userid") == null){
          await storage.saveData("userid", userInfo["userid"]);
        }
        print("Account info obtained successfully!");
        return response;
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getUserProfile() async {
    var uri = Uri.parse(getUserProfileURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Account Profile obtained successfully!");
        return response;
      } else {
        print("Failed to load profile data. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future createUserProfile (accountName, dateofbirth, gender, address, height, weight) async {
    var uri = Uri.parse(createUserProfileURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "userid":  (await storage.getData("userid")).toString(),
          "accountname": accountName,
          "dateofbirth" : dateofbirth,
          "gender" : gender,
          "address" : address,
          "height_cm" : height,
          "weight_kg" : weight
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 201) {
        print("Account Profile created successfully!");
        return response;
      } else {
        print("Failed to create profile. Status code: ${response.statusCode}. Response body: ${response.body}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future updateUserProfile (accountName, dateofbirth, gender, address, height, weight) async {
    var uri = Uri.parse(updateUserProfileURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "userid": (await storage.getData("userid")).toString(),
          "accountname": accountName,
          "dateofbirth" : dateofbirth,
          "gender" : gender,
          "address" : address,
          "height_cm" : height,
          "weight_kg" : weight
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 201) {
        print("Account Profile updated successfully!");
        return response;
      } else {
        print("Failed to update profile. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future updateUserInfo(email, firstname, lastname, phonenumber) async{
    var uri = Uri.parse(updateUserInfoURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "email": email,
          "firstname" : firstname,
          "lastname" : lastname,
          "phonenumber" : phonenumber,
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 202) {
        print("Account info updated successfully!");
        return response;
      } else {
        print("Failed to update account info. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future changePassword(newPassword, confirmPassword) async{
    var uri = Uri.parse(changePasswordURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "new_password": newPassword,
          "confirm_password" : confirmPassword
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 200) {
        print("Password has been changed successfully!");
        return response;
      } else {
        print("Failed to change password. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future banAccount (email) async{
    var uri = Uri.parse(banURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "email": email,
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 200) {
        print("User has been banned!");
        return response;
      } else {
        print("Failed to ban user. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future unbanAccount (email) async{
    var uri = Uri.parse(unbanURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "email": email,
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 200) {
        print("User has been unbanned!");
        return response;
      } else {
        print("Failed to unban user. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }


}
