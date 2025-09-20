import 'package:flutter/material.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Vehicles',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Job Management',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                ],
              ),
            ),

            // Menu items
            _buildDrawerItem(
              icon: Icons.person,
              text: "Manager",
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.directions_car,
              text: "Customer Vehicles",
              selected: true, // highlight example
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              text: "Work Scheduler",
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.people,
              text: "Customers",
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.inventory,
              text: "Parts Inventory",
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.receipt_long,
              text: "Invoice Management",
              onTap: () {},
            ),

            const Spacer(),

            // Logout
            _buildDrawerItem(
              icon: Icons.logout,
              text: "Logout",
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pop(context); // go back to login
              },
            ),
          ],
        ),
      ),

      body: const Center(
        child: Text(
          "Manager Dashboard Content Here",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Drawer item builder
  static Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool selected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      color: selected ? Colors.indigo : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.black),
        title: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
