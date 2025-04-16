import 'package:flutter/material.dart';
import 'package:resturent/features/reservation/reservation_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings navigation
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Account Information',
            children: [
              _buildListTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.location_on,
                title: 'Saved Addresses',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.payment,
                title: 'Payment Methods',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Orders & Reservations',
            children: [
              _buildListTile(
                icon: Icons.receipt_long,
                title: 'Order History',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.table_bar,
                title: 'My Reservations',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationHistoryScreen(),
                    ),
                  );
                },
                subtitle: 'View and manage your table reservations',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Preferences',
            children: [
              _buildListTile(
                icon: Icons.restaurant_menu,
                title: 'Dietary Preferences',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.favorite,
                title: 'Favorite Items',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Support',
            children: [
              _buildListTile(
                icon: Icons.help,
                title: 'Help Center',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.chat,
                title: 'Contact Us',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusChip(
                          context,
                          'Gold Member',
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: _buildStatusChip(
                          context,
                          '150 Points',
                          Icons.currency_exchange,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Icon(
              icon,
              size: 08,
              color: color,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 08),
            ),
          ),
        ],
      ),
    );
  }
}
