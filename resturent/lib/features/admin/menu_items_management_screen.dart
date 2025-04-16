import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturent/models/menu_item.dart';

class MenuItemsManagementScreen extends StatefulWidget {
  const MenuItemsManagementScreen({super.key});

  @override
  State<MenuItemsManagementScreen> createState() =>
      _MenuItemsManagementScreenState();
}

class _MenuItemsManagementScreenState extends State<MenuItemsManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _addMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _firestore.collection('menuItems').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'imageUrl': _imageUrlController.text.trim(),
        'categoryId': _selectedCategoryId,
        'isAvailable': true,
        'isFeatured': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _clearForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _selectedCategoryId = null;
  }

  // Add these new controllers and variables
  final _tagsController = TextEditingController();
  final _sizeController = TextEditingController();
  final _allergyController = TextEditingController();
  final _extraController = TextEditingController();
  final _customizationNameController = TextEditingController();
  final _customizationPriceController = TextEditingController();

  List<String> _selectedSizes = [];
  List<String> _selectedTags = [];
  List<String> _selectedAllergies = [];
  List<String> _selectedExtras = [];
  Map<String, double> _sizePricesMap = {};
  Map<String, double> _extraPricesMap = {};
  Map<String, double> _customizationsMap = {};
  String? _selectedCategoryName;
  final _ingredientsController = TextEditingController();
  // Add these controllers at the top of your state class
  final _prepTimeController = TextEditingController(text: '20');
  final _discountPriceController = TextEditingController();
  bool _isSpicy = false;
  bool _isVegetarian = false;
  List<String> _ingredientsList = [];
  bool _isFeatured = false;
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category dropdown
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const CircularProgressIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      hint: const Text('Select Category'),
                      items: snapshot.data!.docs.map((category) {
                        final data = category.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(data['name'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                      validator: (value) => value == null ? 'Required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name*'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description*'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price*',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(value!) == null)
                              return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _discountPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Discount Price',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Prep Time (minutes)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixText: 'min',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL*',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Checkbox(
                                    value: _isSpicy,
                                    onChanged: (v) =>
                                        setState(() => _isSpicy = v ?? false),
                                  ),
                                ),
                                Flexible(
                                    child: Text(
                                  'Spicy',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Checkbox(
                                    value: _isVegetarian,
                                    onChanged: (v) => setState(
                                        () => _isVegetarian = v ?? false),
                                  ),
                                ),
                                Flexible(
                                    child: Text(
                                  'Vegetarian',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Checkbox(
                                    value: _isFeatured,
                                    onChanged: (v) => setState(
                                        () => _isFeatured = v ?? false),
                                  ),
                                ),
                                Flexible(
                                    child: Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Ingredients input
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Text('Ingredients',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ingredientsController,
                              decoration: const InputDecoration(
                                hintText: 'Add ingredient',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            onPressed: () {
                              if (_ingredientsController.text.isNotEmpty) {
                                setState(() {
                                  _ingredientsList
                                      .add(_ingredientsController.text);
                                  _ingredientsController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_ingredientsList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _ingredientsList
                                .map((ingredient) => Chip(
                                      label: Text(ingredient),
                                      onDeleted: () => setState(() =>
                                          _ingredientsList.remove(ingredient)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Sizes input
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Text('Sizes',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sizeController,
                              decoration: const InputDecoration(
                                hintText:
                                    'Add size (e.g. Small, Medium, Large)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            onPressed: () {
                              if (_sizeController.text.isNotEmpty) {
                                setState(() {
                                  _selectedSizes.add(_sizeController.text);
                                  _sizeController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_selectedSizes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedSizes
                                .map((size) => Chip(
                                      label: Text(size),
                                      onDeleted: () => setState(
                                          () => _selectedSizes.remove(size)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Tags input
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Text('Tags',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagsController,
                              decoration: const InputDecoration(
                                hintText: 'Add tags (comma separated)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            onPressed: () {
                              if (_tagsController.text.isNotEmpty) {
                                setState(() {
                                  _selectedTags
                                      .addAll(_tagsController.text.split(','));
                                  _tagsController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_selectedTags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedTags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      onDeleted: () => setState(
                                          () => _selectedTags.remove(tag)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Allergies input
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Text('Allergies',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _allergyController,
                              decoration: const InputDecoration(
                                hintText: 'Add allergy information',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            onPressed: () {
                              if (_allergyController.text.isNotEmpty) {
                                setState(() {
                                  _selectedAllergies
                                      .add(_allergyController.text);
                                  _allergyController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_selectedAllergies.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedAllergies
                                .map((allergy) => Chip(
                                      label: Text(allergy),
                                      onDeleted: () => setState(() =>
                                          _selectedAllergies.remove(allergy)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Extras input
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Text('Extras',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _extraController,
                              decoration: const InputDecoration(
                                hintText: 'Add extra options',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            onPressed: () {
                              if (_extraController.text.isNotEmpty) {
                                setState(() {
                                  _selectedExtras.add(_extraController.text);
                                  _extraController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_selectedExtras.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedExtras
                                .map((extra) => Chip(
                                      label: Text(extra),
                                      onDeleted: () => setState(
                                          () => _selectedExtras.remove(extra)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Add size prices
                if (_selectedSizes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Size Prices:'),
                  ..._selectedSizes
                      .map((size) => TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Price for $size',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _sizePricesMap[size] = double.parse(value);
                              }
                            },
                          ))
                      .toList(),
                ],

                // Add customizations
                const SizedBox(height: 16),
                const Text('Customizations:'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customizationNameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _customizationPriceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_customizationNameController.text.isNotEmpty &&
                            _customizationPriceController.text.isNotEmpty) {
                          setState(() {
                            _customizationsMap[
                                    _customizationNameController.text] =
                                double.parse(
                                    _customizationPriceController.text);
                            _customizationNameController.clear();
                            _customizationPriceController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                if (_customizationsMap.isNotEmpty)
                  Column(
                    children: _customizationsMap.entries
                        .map((entry) => ListTile(
                              title: Text(entry.key),
                              trailing: Text('\$${entry.value}'),
                              onLongPress: () => setState(
                                  () => _customizationsMap.remove(entry.key)),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _createMenuItem();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final newItem = MenuItem(
        id: FirebaseFirestore.instance.collection('menuItems').doc().id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageUrlController.text.trim(),
        categoryId: _selectedCategoryId ?? '',
        category: _selectedCategoryName ?? 'Uncategorized',
        ingredients: _ingredientsList,
        size: _selectedSizes.isNotEmpty ? _selectedSizes : null,
        tags: _selectedTags,
        isAvailable: true,
        isSpicy: _isSpicy,
        isVegetarian: _isVegetarian,
        discountPrice: _discountPriceController.text.isNotEmpty
            ? double.tryParse(_discountPriceController.text)
            : null,
        sizePrices: _sizePricesMap.isNotEmpty ? _sizePricesMap : const {},
        extraPrices: _extraPricesMap.isNotEmpty ? _extraPricesMap : const {},
        extras: _selectedExtras,
        customizations:
            _customizationsMap.isNotEmpty ? _customizationsMap : null,
        allergies: _selectedAllergies.isNotEmpty ? _selectedAllergies : null,
        rating: 0.0,
        reviewCount: 0,
        preparationTime: int.tryParse(_prepTimeController.text) ?? 20,
      );

      await FirebaseFirestore.instance
          .collection('menuItems')
          .doc(newItem.id)
          .set(newItem.toJson());

      if (mounted) {
        _clearForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Items Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('menuItems').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final data = item.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                ),
                title: Text(data['name'] ?? ''),
                subtitle: Text(
                  '${data['description'] ?? ''}\nPrice: \$${data['price']?.toString() ?? '0.00'}',
                ),
                trailing: Switch(
                  value: data['isAvailable'] ?? false,
                  onChanged: (value) {
                    item.reference.update({'isAvailable': value});
                  },
                ),
                onTap: () {
                  // TODO: Implement edit menu item
                },
              );
            },
          );
        },
      ),
    );
  }
}
