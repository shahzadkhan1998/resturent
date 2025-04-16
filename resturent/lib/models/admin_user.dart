import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String id;
  final String email;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}