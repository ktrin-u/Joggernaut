// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserAuth {
  int authId;
  int userId;
  String passwordHash;
  UserAuth({
    required this.authId,
    required this.userId,
    required this.passwordHash,
  });

  UserAuth copyWith({
    int? authId,
    int? userId,
    String? passwordHash,
  }) {
    return UserAuth(
      authId: authId ?? this.authId,
      userId: userId ?? this.userId,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'authId': authId,
      'userId': userId,
      'passwordHash': passwordHash,
    };
  }

  factory UserAuth.fromMap(Map<String, dynamic> map) {
    return UserAuth(
      authId: map['authId'] as int,
      userId: map['userId'] as int,
      passwordHash: map['passwordHash'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAuth.fromJson(String source) => UserAuth.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserAuth(authId: $authId, userId: $userId, passwordHash: $passwordHash)';

  @override
  bool operator ==(covariant UserAuth other) {
    if (identical(this, other)) return true;
  
    return 
      other.authId == authId &&
      other.userId == userId &&
      other.passwordHash == passwordHash;
  }

  @override
  int get hashCode => authId.hashCode ^ userId.hashCode ^ passwordHash.hashCode;
}
