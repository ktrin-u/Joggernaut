// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';

class ApiService {
  var client = http.Client();
  final SecureStorageService storage = SecureStorageService();

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

  Future getWorkout() async {
    var uri = Uri.parse(getWorkoutURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Workout obtained successfully!");
        return response;
      } else {
        print("Failed to load workout data. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
  
  Future createWorkout (steps, calories) async {
    var uri = Uri.parse(createWorkoutURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "calories": calories.toString(), 
          "steps": steps.toString(),       
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 200) {
        print("Workout session created successfully!");
        return response;
      } else {
        print("Failed to create workout session. Status code: ${response.statusCode}. Response body: ${response.body}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future updateWorkout (workoutID, steps, calories) async {
    var uri = Uri.parse(updateWorkoutURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "workoutid": workoutID.toString(),
          "calories": calories.toString(), 
          "steps": steps.toString(),       
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 201) {
        print("Workout session updated successfully!");
        return response;
      } else {
        print("Failed to update workout session. Status code: ${response.statusCode}. Response body: ${response.body}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getAllUsers() async {
    var uri = Uri.parse(getAllUsersURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("All users obtained successfully!");
        return response;
      } else {
        print("Failed to load all users data. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getFriends() async {
    var uri = Uri.parse(getFriendsURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("All friends obtained successfully!");
        return response;
      } else {
        print("Failed to load all friends. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getFriendActivity() async {
    var uri = Uri.parse(getActivitiesURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Friend activities obtained successfully!");
        return response;
      } else {
        print("Failed to load friend activities. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future addFriend(friendId) async {
    var uri = Uri.parse(addFriendURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "toUserid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 201) {
        print("Friend Request sent successfully!");
        return response;
      } else {
        print("Failed to send friend request. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future pokeFriend(friendId) async {
    var uri = Uri.parse(pokeFriendURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "toUserid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 201) {
        print("Friend poked successfully!");
        return response;
      } else {
        print("Failed to poke friend. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future cancelRequest(friendId) async {
    var uri = Uri.parse(cancelRequestURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "toUserid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Friend Request cancelled successfully!");
        return response;
      } else {
        print("Failed to cancel friend request. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future acceptRequest(friendId) async {
    var uri = Uri.parse(acceptRequestURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "fromUserid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Friend Request accepted successfully!");
        return response;
      } else {
        print("Failed to accept friend request. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future rejectRequest(friendId) async {
    var uri = Uri.parse(rejectRequestURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "fromUserid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Friend Request rejected successfully!");
        return response;
      } else {
        print("Failed to reject friend request. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future unFriend(friendId) async {
    var uri = Uri.parse(unFriendURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "targetid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Unfriended successfully!");
        return response;
      } else {
        print("Failed to unfried. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getPendingFriends() async {
    var uri = Uri.parse(getPendingFriendsURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Pending friend requests obtained successfully!");
        return response;
      } else {
        print("Failed to load pending friend requests. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future addChallenge(friendId) async {
    var uri = Uri.parse(challengeFriendURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "durationSecs": "3600",
          "toUserid": friendId,
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 201) {
        print("Friend challenged successfully!");
        return response;
      } else {
        print("Failed to challenge friend. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future acceptChallenge(friendId, activityId) async {
    var uri = Uri.parse(acceptActivityURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "activityid": activityId.toString()
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Challenge accepted successfully!");
        return response;
      } else if (response.statusCode == 400){
        print("Failed to accept challenge. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future rejectChallenge(friendId, activityId) async {
    var uri = Uri.parse(rejectActivityURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "activityid": activityId.toString()
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Challenge rejected successfully!");
        return response;
      } else {
        print("Failed to reject challenge. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future cancelChallenge(friendId, activityId) async {
    var uri = Uri.parse(cancelActivityURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "activityid": activityId.toString()
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Challenge cancelled successfully!");
        return response;
      } else {
        print("Failed to cancel challenge. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
