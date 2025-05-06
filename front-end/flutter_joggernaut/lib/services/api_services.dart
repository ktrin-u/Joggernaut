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

  Future updateUserProfile (accountName, dateofbirth, gender, height, weight) async {
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

  Future updateUserInfo(firstname, lastname, phonenumber) async{
    var uri = Uri.parse(updateUserInfoURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "firstname" : firstname,
          "lastname" : lastname,
          "phonenumber" : phonenumber,
        },
        encoding: Encoding.getByName('utf-8')
      );
      if (response.statusCode == 200) {
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

  Future getWorkout(userid) async {
    var uri = Uri.parse(workoutURL).replace(queryParameters: {
      "userid": userid.toString()
    });
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
    var uri = Uri.parse(workoutURL);
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
      if (response.statusCode == 201) {
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
    var uri = Uri.parse(workoutURL);
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
          "durationSecs": "0",
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

  Future addChallenge(friendId, duration) async {
    var uri = Uri.parse(challengeFriendURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "durationSecs": duration,
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

  Future acceptChallenge(activityId) async {
    var uri = Uri.parse(updateActivityURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "activityid": activityId.toString(),
          "status": "ONG"
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

  Future rejectChallenge(activityId) async {
    var uri = Uri.parse(updateActivityURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "activityid": activityId.toString(),
          "status": "REJ"
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

  Future cancelChallenge(activityId) async {
    var uri = Uri.parse(updateActivityURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "activityid": activityId.toString(),
          "status": "CAN"
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

  Future getCharacters() async {
    var uri = Uri.parse(characterURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Characters obtained successfully!");
        return response;
      } else {
        print("Failed to load my characters. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future createCharacter(name, type, color) async {
    var uri = Uri.parse(characterURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
        body: {
          "name": name,
          "type": type.toUpperCase(),
          "color": color.toUpperCase(),
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 201) {
        print("Character created successfully!");
        return response;
      } else {
        print("Failed to create character. Status code: ${response.body}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future deleteCharacter(characterid) async {
    var uri = Uri.parse(characterURL).replace(queryParameters: {
      "id": characterid.toString()
    });
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.delete(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        }, 
      );

      if (response.statusCode == 200) {
        print("Character deleted successfully!");
        return response;
      } else {
        print("Failed to delete character. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future selectCharacter(characterid) async {
    var uri = Uri.parse(characterURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        }, 
      body: {
          "id": characterid.toString(),
          "selected": "true"
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 200) {
        print("Character selected successfully!");
        return response;
      } else {
        print("Failed to select character. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future updateCharacter(characterid, type, color, name) async {
    var uri = Uri.parse(characterURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.patch(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        }, 
      body: {
          "id": characterid.toString(),
          "name": name,
          "color": color.toUpperCase(),
          "type": type.toUpperCase(),
        },
        encoding: Encoding.getByName('utf-8')
      );

      if (response.statusCode == 202) {
        print("Character updateed successfully!");
        return response;
      } else {
        print("Failed to update character. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getGameSave() async {
    var uri = Uri.parse(gameSaveURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Game save obtained successfully!");
        return response;
      } else {
        print("Failed to load game save. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future getLeaderboards(category) async {
    var uri = Uri.parse(leaderboardURL).replace(queryParameters: {
      "category": category,
      "top_n": "10"
    });
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.get(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Leaderboard obtained successfully!");
        return response;
      } else {
        print("Failed to load leaderboards. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
  
  Future postGameStats() async {
    var uri = Uri.parse(gameStatsURL);
    String? accessToken = await storage.getAccessToken();
    try {
      var response = await client.post(uri, 
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        }, 
      );

      if (response.statusCode == 200) {
        print("Game stat added successfully!");
        return response;
      } else {
        print("Failed to add game stat. Status code: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
