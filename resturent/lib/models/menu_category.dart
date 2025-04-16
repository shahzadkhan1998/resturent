class MenuCategory {
  final String id;
  final String name;
  final String? description; // Changed to nullable String?
  final String? imageUrl; // Changed to nullable String?
  final int displayOrder;
  final bool isActive;
  final String? parentCategoryId;
  final List<String> tags;

  MenuCategory({
    required this.id,
    required this.name,
    this.description = '', // Removed required, added default value
    this.imageUrl = '', // Removed required, added default value
    this.displayOrder = 0,
    this.isActive = true,
    this.parentCategoryId,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'displayOrder': displayOrder,
        'isActive': isActive,
        'parentCategoryId': parentCategoryId,
        'tags': tags,
      };

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '', // Added null check with default
        imageUrl: json['imageUrl'] ?? '', // Added null check with default
        displayOrder: json['displayOrder'] ?? 0,
        isActive: json['isActive'] ?? true,
        parentCategoryId: json['parentCategoryId'],
        tags: List<String>.from(json['tags'] ?? []),
      );

  MenuCategory copyWith({
    String? id,
    String? name,
    String? description, // Changed parameter type to String?
    String? imageUrl, // Changed parameter type to String?
    int? displayOrder,
    bool? isActive,
    String? parentCategoryId,
    List<String>? tags,
  }) =>
      MenuCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        displayOrder: displayOrder ?? this.displayOrder,
        isActive: isActive ?? this.isActive,
        parentCategoryId: parentCategoryId ?? this.parentCategoryId,
        tags: tags ?? this.tags,
      );
}
