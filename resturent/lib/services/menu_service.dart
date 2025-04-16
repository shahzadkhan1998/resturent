import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturent/models/menu_item.dart';
import 'package:resturent/models/menu_category.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all menu categories
  Stream<List<MenuCategory>> getCategories() {
    return _firestore
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuCategory.fromJson(doc.data()))
            .toList());
  }

  // Get menu items by category
  Stream<List<MenuItem>> getMenuItemsByCategory(String categoryId) {
    return _firestore
        .collection('menuItems')
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  // Get featured menu items
  Stream<List<MenuItem>> getFeaturedItems() {
    return _firestore
        .collection('menuItems')
        .where('isAvailable', isEqualTo: true)
        .where('tags', arrayContains: 'featured')
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  // Get popular menu items
  Stream<List<MenuItem>> getPopularItems() {
    return _firestore
        .collection('menuItems')
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  // Search menu items
  Future<List<MenuItem>> searchMenuItems(String query) async {
    // Search in name and description
    final nameResults = await _firestore
        .collection('menuItems')
        .where('isAvailable', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final descResults = await _firestore
        .collection('menuItems')
        .where('isAvailable', isEqualTo: true)
        .where('description', isGreaterThanOrEqualTo: query)
        .where('description', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Combine and remove duplicates
    final items = {...nameResults.docs, ...descResults.docs}
        .map((doc) => MenuItem.fromJson(doc.data()))
        .toList();

    return items;
  }

  // Filter menu items
  Future<List<MenuItem>> filterMenuItems({
    bool? isVegetarian,
    bool? isSpicy,
    double? maxPrice,
    List<String>? tags,
    List<String>? allergies,
  }) async {
    Query query = _firestore
        .collection('menuItems')
        .where('isAvailable', isEqualTo: true);

    if (isVegetarian != null) {
      query = query.where('isVegetarian', isEqualTo: isVegetarian);
    }

    if (isSpicy != null) {
      query = query.where('isSpicy', isEqualTo: isSpicy);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    final results = await query.get();
    var items = results.docs
        .map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Apply price filter (can't be done in query due to Firestore limitations)
    if (maxPrice != null) {
      items = items.where((item) => item.finalPrice <= maxPrice).toList();
    }

    // Apply allergies filter
    if (allergies != null && allergies.isNotEmpty) {
      items = items.where((item) {
        if (item.allergies == null) return true;
        return !item.allergies!.any((allergy) => allergies.contains(allergy));
      }).toList();
    }

    return items;
  }

  // Get menu item by ID
  Future<MenuItem?> getMenuItem(String itemId) async {
    final doc = await _firestore.collection('menuItems').doc(itemId).get();
    if (!doc.exists) return null;
    return MenuItem.fromJson(doc.data()!);
  }

  // Get menu items by IDs
  Future<List<MenuItem>> getMenuItemsByIds(List<String> itemIds) async {
    if (itemIds.isEmpty) return [];

    final snapshots = await Future.wait(
      itemIds.map((id) => _firestore.collection('menuItems').doc(id).get()),
    );

    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => MenuItem.fromJson(doc.data()!))
        .toList();
  }

  // Get special offers and discounted items
  Stream<List<MenuItem>> getSpecialOffers() {
    return _firestore
        .collection('menuItems')
        .where('isAvailable', isEqualTo: true)
        .where('discountPrice', isNull: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }
}
