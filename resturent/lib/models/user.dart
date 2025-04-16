import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String membershipLevel;
  final int loyaltyPoints;
  final List<String> dietaryPreferences;
  final List<String> favoriteItems;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.membershipLevel = 'Bronze',
    this.loyaltyPoints = 0,
    this.dietaryPreferences = const [],
    this.favoriteItems = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'membershipLevel': membershipLevel,
        'loyaltyPoints': loyaltyPoints,
        'dietaryPreferences': dietaryPreferences,
        'favoriteItems': favoriteItems,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        photoUrl: json['photoUrl'],
        membershipLevel: json['membershipLevel'] ?? 'Bronze',
        loyaltyPoints: json['loyaltyPoints'] ?? 0,
        dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
        favoriteItems: List<String>.from(json['favoriteItems'] ?? []),
      );

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? membershipLevel,
    int? loyaltyPoints,
    List<String>? dietaryPreferences,
    List<String>? favoriteItems,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        membershipLevel: membershipLevel ?? this.membershipLevel,
        loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
        dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
        favoriteItems: favoriteItems ?? this.favoriteItems,
      );
}


class AppUser {
  final String uid;
  final String email;
  final bool isAdmin;
  final String? name;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.isAdmin,
    this.name,
    this.photoUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email']?.toString() ?? '',
      isAdmin: data['isAdmin'] as bool? ?? false,
      name: data['name']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAdmin': isAdmin,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
