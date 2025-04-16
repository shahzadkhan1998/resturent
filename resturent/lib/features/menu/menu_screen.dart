import 'package:flutter/material.dart';
import 'package:resturent/models/menu_category.dart';
import 'package:resturent/models/menu_item.dart';
import 'package:resturent/services/menu_service.dart';
import 'package:resturent/features/menu/widgets/menu_item_card.dart';
import 'package:resturent/features/menu/widgets/category_card.dart';
import 'package:resturent/features/menu/menu_search_screen.dart';
import 'package:resturent/features/menu/menu_item_details_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  final _menuService = MenuService();
  late TabController _tabController;
  String? _selectedCategoryId;
  bool _showFilters = false;
  final _filters = MenuFilters();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Featured'),
            Tab(text: 'Offers'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(),
                _buildFeaturedTab(),
                _buildOffersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Vegetarian Only'),
              value: _filters.isVegetarian,
              onChanged: (value) {
                setState(() {
                  _filters.isVegetarian = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Spicy'),
              value: _filters.isSpicy,
              onChanged: (value) {
                setState(() {
                  _filters.isSpicy = value;
                });
              },
            ),
            Slider(
              value: _filters.maxPrice,
              min: 0,
              max: 100,
              divisions: 20,
              label: '\$${_filters.maxPrice.toStringAsFixed(2)}',
              onChanged: (value) {
                setState(() {
                  _filters.maxPrice = value;
                });
              },
            ),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Gluten-Free'),
                  selected: _filters.tags.contains('gluten-free'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters.tags.add('gluten-free');
                      } else {
                        _filters.tags.remove('gluten-free');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Dairy-Free'),
                  selected: _filters.tags.contains('dairy-free'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters.tags.add('dairy-free');
                      } else {
                        _filters.tags.remove('dairy-free');
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return StreamBuilder<List<MenuCategory>>(
      stream: _menuService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data ?? [];
        return Column(
          children: [
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    isSelected: category.id == _selectedCategoryId,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: _selectedCategoryId == null
                  ? const Center(
                      child: Text('Select a category to view items'),
                    )
                  : StreamBuilder<List<MenuItem>>(
                      stream: _menuService
                          .getMenuItemsByCategory(_selectedCategoryId!),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final items = snapshot.data ?? [];
                        final filteredItems = _applyFilters(items);

                        if (filteredItems.isEmpty) {
                          return const Center(
                            child: Text('No items match your filters'),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return MenuItemCard(
                              item: filteredItems[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MenuItemDetailsScreen(
                                      item: filteredItems[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedTab() {
    return StreamBuilder<List<MenuItem>>(
      stream: _menuService.getFeaturedItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        final filteredItems = _applyFilters(items);

        if (filteredItems.isEmpty) {
          return const Center(
            child: Text('No featured items match your filters'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return MenuItemCard(
              item: filteredItems[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuItemDetailsScreen(
                      item: filteredItems[index],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOffersTab() {
    return StreamBuilder<List<MenuItem>>(
      stream: _menuService.getSpecialOffers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        final filteredItems = _applyFilters(items);

        if (filteredItems.isEmpty) {
          return const Center(
            child: Text('No special offers match your filters'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return MenuItemCard(
              item: filteredItems[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuItemDetailsScreen(
                      item: filteredItems[index],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<MenuItem> _applyFilters(List<MenuItem> items) {
    return items.where((item) {
      if (_filters.isVegetarian && !item.isVegetarian) return false;
      if (_filters.isSpicy && !item.isSpicy) return false;
      if (item.finalPrice > _filters.maxPrice) return false;
      if (_filters.tags.isNotEmpty &&
          !item.tags.any((tag) => _filters.tags.contains(tag))) {
        return false;
      }
      return true;
    }).toList();
  }
}

class MenuFilters {
  bool isVegetarian = false;
  bool isSpicy = false;
  double maxPrice = 100;
  Set<String> tags = {};
}
