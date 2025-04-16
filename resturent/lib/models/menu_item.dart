class MenuItem {
  final String id;
  final String name;
  final List<String>? size;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final List<String> tags;
  final bool isAvailable;
  final bool isSpicy;
  final bool isVegetarian;
  final List<String> ingredients;
  final double? discountPrice;
  final Map<String, double> sizePrices;
  final Map<String, double> extraPrices;
  final List<String> extras;
  final Map<String, double>? customizations;
  final List<String>? allergies;
  final double rating;
  final String category;
  final int reviewCount;
  final int preparationTime; // in minutes

  MenuItem({
    required this.id,
    this.size,
    required this.name,
    required this.category,
    required this.ingredients,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.tags = const [],
    this.isAvailable = true,
    this.isSpicy = false,
    this.isVegetarian = false,
    this.discountPrice,
    this.sizePrices = const {},
    this.extraPrices = const {},
    this.extras = const [],
    this.customizations,
    this.allergies,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.preparationTime = 20,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'category': category,
        'ingredients': ingredients,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'tags': tags,
        'isAvailable': isAvailable,
        'isSpicy': isSpicy,
        'isVegetarian': isVegetarian,
        'discountPrice': discountPrice,
        'sizePrices': sizePrices,
        'extraPrices': extraPrices,
        'extras': extras,
        'customizations': customizations,
        'allergies': allergies,
        'rating': rating,
        'reviewCount': reviewCount,
        'preparationTime': preparationTime,
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        size: json['size'] != null ? List<String>.from(json['size']) : null,
        category: json['category'],
        ingredients: List<String>.from(json['ingredients'] ?? []),
        description: json['description'],
        price: json['price'].toDouble(),
        imageUrl: json['imageUrl'],
        categoryId: json['categoryId'],
        tags: List<String>.from(json['tags'] ?? []),
        isAvailable: json['isAvailable'] ?? true,
        isSpicy: json['isSpicy'] ?? false,
        isVegetarian: json['isVegetarian'] ?? false,
        discountPrice: json['discountPrice']?.toDouble(),
        sizePrices: Map<String, double>.from(json['sizePrices'] ?? {}),
        extraPrices: Map<String, double>.from(json['extraPrices'] ?? {}),
        extras: List<String>.from(json['extras'] ?? []),
        customizations: json['customizations'] != null
            ? Map<String, double>.from(json['customizations'])
            : null,
        allergies: json['allergies'] != null
            ? List<String>.from(json['allergies'])
            : null,
        rating: json['rating']?.toDouble() ?? 0.0,
        reviewCount: json['reviewCount'] ?? 0,
        preparationTime: json['preparationTime'] ?? 20,
      );

  MenuItem copyWith({
    String? id,
    String? name,
    List<String>? size,
    String? description,
    double? price,
    String? category,
    List<String>? ingredients,
    String? imageUrl,
    String? categoryId,
    List<String>? tags,
    bool? isAvailable,
    bool? isSpicy,
    bool? isVegetarian,
    double? discountPrice,
    Map<String, double>? sizePrices,
    Map<String, double>? extraPrices,
    List<String>? extras,
    Map<String, double>? customizations,
    List<String>? allergies,
    double? rating,
    int? reviewCount,
    int? preparationTime,
  }) =>
      MenuItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        size: size ?? this.size,
        ingredients: ingredients ?? this.ingredients,
        description: description ?? this.description,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        categoryId: categoryId ?? this.categoryId,
        tags: tags ?? this.tags,
        isAvailable: isAvailable ?? this.isAvailable,
        isSpicy: isSpicy ?? this.isSpicy,
        isVegetarian: isVegetarian ?? this.isVegetarian,
        discountPrice: discountPrice ?? this.discountPrice,
        sizePrices: sizePrices ?? this.sizePrices,
        extraPrices: extraPrices ?? this.extraPrices,
        extras: extras ?? this.extras,
        customizations: customizations ?? this.customizations,
        allergies: allergies ?? this.allergies,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        preparationTime: preparationTime ?? this.preparationTime,
      );

  double get finalPrice => discountPrice ?? price;
}
