import 'package:flutter/material.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/remittance/remittance_history_list_page.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/settings/settings_page.dart';

      class DashboardPage extends StatefulWidget {
        const DashboardPage({super.key});

        @override
        State<DashboardPage> createState() => _DashboardPageState();
      }

      class _DashboardPageState extends State<DashboardPage> {
        int _selectedIndex = 0;

        late final List<Widget> _pages = <Widget>[
          _buildDashboardPage(),
          const Center(child: Text('Clients')),
          const RemittancePage(),
          const SettingsPage(),
        ];

        @override
        Widget build(BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Agent Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Hello, Engineer', style: TextStyle(fontSize: 12)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text('E', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
                BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Remittances'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blueAccent,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          );
        }

        Widget _buildDashboardPage() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('Active Policies', '124', Colors.blue, Icons.folder_shared),
                    const SizedBox(width: 12),
                    _buildStatCard('Monthly Premium', '\$12k', Colors.green, Icons.attach_money),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('Pending Claims', '3', Colors.orange, Icons.warning_amber),
                    const SizedBox(width: 12),
                    _buildStatCard('Renewals Due', '8', Colors.redAccent, Icons.event_repeat),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildActivityTile(
                  clientName: 'Juan Dela Cruz',
                  policyType: 'Life Insurance',
                  status: 'Approved',
                  time: '2 hrs ago',
                  statusColor: Colors.green,
                ),
                _buildActivityTile(
                  clientName: 'Maria Clara',
                  policyType: 'Car Insurance',
                  status: 'Pending Payment',
                  time: '5 hrs ago',
                  statusColor: Colors.orange,
                ),
                _buildActivityTile(
                  clientName: 'Jose Rizal',
                  policyType: 'Property Insurance',
                  status: 'Under Review',
                  time: '1 day ago',
                  statusColor: Colors.blue,
                ),
                _buildActivityTile(
                  clientName: 'Andres Bonifacio',
                  policyType: 'Life Insurance',
                  status: 'Rejected',
                  time: '2 days ago',
                  statusColor: Colors.red,
                ),
              ],
            ),
          );
        }

        Widget _buildStatCard(String title, String value, Color color, IconData icon) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, color: color, size: 28),
                      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
          );
        }

        Widget _buildActivityTile({
          required String clientName,
          required String policyType,
          required String status,
          required String time,
          required Color statusColor,
        }) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Text(clientName[0], style: TextStyle(color: Colors.blue.shade800)),
              ),
              title: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(policyType),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          );
        }
      }