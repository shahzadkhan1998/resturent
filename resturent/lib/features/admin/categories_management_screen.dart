import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturent/models/menu_category.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController(); // Add this
  final _imageUrlController = TextEditingController();
  final _displayOrderController = TextEditingController(); // Add this
  final _tagsController = TextEditingController();
  String? _selectedParentCategoryId; // Add this
  List<String> _selectedTags = []; // Add this
  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose(); // Add this
    _imageUrlController.dispose();
    _displayOrderController.dispose(); // Add this
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _firestore.collection('categories').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(), // Added
        'imageUrl': _imageUrlController.text.trim(),
        'isActive': true,
        'displayOrder': _displayOrderController.text.isEmpty
            ? 0
            : int.parse(_displayOrderController.text), // Updated
        'parentCategoryId': _selectedParentCategoryId, // Added
        'tags': _selectedTags, // Added
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _nameController.clear();
        _descriptionController.clear(); // Added
        _imageUrlController.clear();
        _displayOrderController.clear(); // Added
        _tagsController.clear(); // Added
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

  void _showAddDialog() {
    // These controllers should already be declared at the class level
    _descriptionController.clear();
    _displayOrderController.text = '0';
    _selectedParentCategoryId = null;
    _selectedTags.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name*'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Make sure all these fields are included:
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _displayOrderController,
                  decoration: const InputDecoration(labelText: 'Display Order'),
                  keyboardType: TextInputType.number,
                ),
                // Parent category dropdown
                SizedBox(
                  height: 10,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Flexible(
                      child: DropdownButtonFormField<String>(
                        value: _selectedParentCategoryId,
                        hint: Text(
                          'Parent Category (Optional)',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ),
                        items: snapshot.data!.docs.map((category) {
                          final data = category.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(data['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedParentCategoryId = value),
                      ),
                    );
                  },
                ),

                SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL*'),
                ),
                SizedBox(
                  height: 10,
                ),

                // Tags input
                TextField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Add tags separated by commas',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final tags = _tagsController.text.split(',');
                        if (_tagsController.text.isNotEmpty) {
                          setState(() {
                            _selectedTags.addAll(tags
                                .map((t) => t.trim())
                                .where((t) => t.isNotEmpty));
                            _tagsController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (_selectedTags.isNotEmpty)
                  Wrap(
                    children: _selectedTags
                        .map((tag) => Chip(
                              label: Text(tag),
                              onDeleted: () =>
                                  setState(() => _selectedTags.remove(tag)),
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
                await _createCategory();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory() async {
    final newCategory = MenuCategory(
      id: FirebaseFirestore.instance.collection('categories').doc().id,
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      displayOrder: _displayOrderController.text.isEmpty
          ? 0
          : int.parse(_displayOrderController.text),
      isActive: true,
      parentCategoryId: _selectedParentCategoryId,
      tags: _selectedTags,
    );

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(newCategory.id)
        .set(newCategory.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final data = category.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                ),
                title: Text(data['name'] ?? ''),
                trailing: Switch(
                  value: data['isActive'] ?? false,
                  onChanged: (value) {
                    category.reference.update({'isActive': value});
                  },
                ),
                onTap: () {
                  // TODO: Implement edit category
                },
              );
            },
          );
        },
      ),
    );
  }
}
