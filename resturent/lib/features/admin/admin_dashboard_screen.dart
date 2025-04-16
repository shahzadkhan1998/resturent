import 'package:flutter/material.dart';
import 'package:resturent/features/admin/categories_management_screen.dart';
import 'package:resturent/features/admin/menu_items_management_screen.dart';
import 'package:resturent/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/admin/login');
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        children: [
          _DashboardCard(
            title: 'Categories',
            icon: Icons.category,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoriesManagementScreen(),
              ),
            ),
          ),
          _DashboardCard(
            title: 'Menu Items',
            icon: Icons.restaurant_menu,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MenuItemsManagementScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
