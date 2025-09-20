import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = "https://fslfjrhryjroacsfxaqf.supabase.co";
const String supabaseKey = "sb_secret_zUCpJBBsUhiE8kXJYjS74w_LDv5_gZO";

class Vehicles {
  final String id;
  final String plate_number;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String status;
  final String customer;

  Vehicles({
    required this.id,
    required this.plate_number,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.status,
    required this.customer,
  });

  factory Vehicles.fromJson(Map<String, dynamic> json) {
    return Vehicles(
      id: json['id'].toString(),
      plate_number: json['plate_number'] ?? '-',
      make: json['make'] ?? '-',
      model: json['model'] ?? '-',
      year: json['year'] ?? '-',
      vin: json['vin'] ?? '-',
      status: json['status'] ?? '-',
      customer: json['owner_name'] ?? '-',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: vehicleManagement()));
}

class vehicleManagement extends StatefulWidget {
  const vehicleManagement({super.key});
  @override
  State<vehicleManagement> createState() => _vehicleManagementState();
}

class _vehicleManagementState extends State<vehicleManagement> {
  final supabase = Supabase.instance.client;
  int _selectedPage = 1;

  List<Vehicles> _vehicles = [];
  bool _isLoading = true;

  // Pagination
  int _page = 0;
  final int _limit = 5;

  // Search
  String _searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);

    try {
      final response = _searchQuery.isEmpty
        ? await supabase
          .from('VehicleOwner')
          .select()
          .range(_page * _limit, (_page + 1) * _limit - 1)
        : await supabase
          .from('VehicleOwner')
          .select()
          .or('owner_name.ilike.%$_searchQuery%, vin.ilike.%$_searchQuery%, plate_number.ilike.%$_searchQuery%')
          .range(_page * _limit, (_page + 1) * _limit - 1);

      final vehicles = (response as List).map((item) {
        return Vehicles.fromJson(item);
      }).toList();

      setState(() {
        _vehicles = vehicles;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching vehicles: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    setState(() {
      _page++;
    });
    _fetchVehicles();
  }

  void _prevPage() {
    if (_page > 0) {
      setState(() {
        _page--;
      });
      _fetchVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Vehicles',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVehicles,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehiclePage()),
          );
        },
      ),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Job Management',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              text: "Manager Account",
              selected: _selectedPage == 0,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.directions_car,
              text: "Vehicles",
              selected: _selectedPage == 1,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              text: "Work Scheduler",
              selected: _selectedPage == 2,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.people,
              text: "Customers",
              selected: _selectedPage == 3,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.inventory,
              text: "Parts Inventory",
              selected: _selectedPage == 4,
              onTap: () {},
            ),
            const Spacer(),
            _buildDrawerItem(
              icon: Icons.logout,
              text: "Logout",
              customColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by customer, VIN, or plate no...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                // Clear search
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                      _fetchVehicles();
                    },
                  )
                  : null,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _fetchVehicles();
              },
            ),
          ),

          // Vehicle list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty
                ? const Center(child: Text("No vehicles found."))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final v = _vehicles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(v.model.split(" ").first,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold)
                      ),
                    ),
                    title: Text("${v.model}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Customer: ${v.customer}"),
                        Text("VIN: ${v.vin}"),
                        Text("Status: ${v.status}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(v.status))
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: (){

                    },
                  ),
                );
              },
            ),
          ),

          // Pagination controls
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: _prevPage, icon: const Icon(Icons.arrow_back)),
                  Text("Page ${_page + 1}"),
                  IconButton(onPressed: _nextPage, icon: const Icon(Icons.arrow_forward)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "in service":
        return Colors.red;
      case "ready for pickup":
        return Colors.green;
      case "waiting for parts":
        return Colors.orange;
      case "completed":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool selected = false,
    Color? customColor,
  }) {
    final color = customColor ?? (selected ? Colors.indigo : Colors.black87);

    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.indigo.shade50 : Colors.transparent, // background highlight
        border: selected
            ? Border(
          left: BorderSide(color: Colors.indigo, width: 4), // left color bar
        )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// Simple Add Vehicle Page
class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Vehicle")),
      body: const Center(
        child: Text("Form to add vehicle goes here."),
      ),
    );
  }
}
