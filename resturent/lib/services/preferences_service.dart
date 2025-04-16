import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturent/models/user_preferences.dart';

class PreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserPreferences> getUserPreferences(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('settings')
        .get();

    if (doc.exists) {
      return UserPreferences.fromJson(doc.data()!);
    }

    // Return default preferences if none exist
    return UserPreferences();
  }

  Future<void> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('settings')
        .set(preferences.toJson());
  }

  Stream<UserPreferences> userPreferencesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('settings')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserPreferences.fromJson(doc.data()!);
      }
      return UserPreferences();
    });
  }
}
