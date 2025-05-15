import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final Timestamp birthday;
  final String city;
  final String about;
  final String avatarUrl;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.about,
    required this.birthday,
    required this.avatarUrl,
  });

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      birthday: map['birthday'] ?? '',
      city: map['city'] ?? '',
      about: map['about'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'city': city,
      'about': about,
      'avatar_url': avatarUrl,
    };
  }

  String toDate() {
    return DateFormat('dd.MM.yyyy').format(birthday.toDate());
  }
}
