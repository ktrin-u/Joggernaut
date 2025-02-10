// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserProfile {
  int userId;
  int profileId;
  String firstName;
  String lastName;
  String dateOfBirth;
  String gender;
  UserProfile({
    required this.userId,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
  });

  UserProfile copyWith({
    int? userId,
    int? profileId,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'profileId': profileId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] as int,
      profileId: map['profileId'] as int,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      dateOfBirth: map['dateOfBirth'] as String,
      gender: map['gender'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserProfile(userId: $userId, profileId: $profileId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender)';
  }

  @override
  bool operator ==(covariant UserProfile other) {
    if (identical(this, other)) return true;
  
    return 
      other.userId == userId &&
      other.profileId == profileId &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.dateOfBirth == dateOfBirth &&
      other.gender == gender;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      profileId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      dateOfBirth.hashCode ^
      gender.hashCode;
  }
}
