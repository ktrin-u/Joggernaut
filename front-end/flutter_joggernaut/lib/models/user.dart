// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  int id;
  String email;
  String phoneNumber;
  User({
    required this.id,
    required this.email,
    required this.phoneNumber,
  });

 

  User copyWith({
    int? id,
    String? email,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(id: $id, email: $email, phoneNumber: $phoneNumber)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.email == email &&
      other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ phoneNumber.hashCode;
}
