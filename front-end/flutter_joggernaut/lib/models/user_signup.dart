// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CreateUser {
  String firstname;
  String lastname;
  String email;
  String phonenumber;
  String password;
  CreateUser({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phonenumber,
    required this.password,
  });

  CreateUser copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phonenumber,
    String? password,
  }) {
    return CreateUser(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phonenumber: phonenumber ?? this.phonenumber,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phonenumber': phonenumber,
      'password': password,
    };
  }

  factory CreateUser.fromMap(Map<String, dynamic> map) {
    return CreateUser(
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      email: map['email'] as String,
      phonenumber: map['phonenumber'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateUser.fromJson(String source) => CreateUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CreateUser(firstname: $firstname, lastname: $lastname, email: $email, phonenumber: $phonenumber, password: $password)';
  }

  @override
  bool operator ==(covariant CreateUser other) {
    if (identical(this, other)) return true;
  
    return 
      other.firstname == firstname &&
      other.lastname == lastname &&
      other.email == email &&
      other.phonenumber == phonenumber &&
      other.password == password;
  }

  @override
  int get hashCode {
    return firstname.hashCode ^
      lastname.hashCode ^
      email.hashCode ^
      phonenumber.hashCode ^
      password.hashCode;
  }
}
