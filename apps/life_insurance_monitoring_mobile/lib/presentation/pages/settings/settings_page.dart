import 'package:flutter/material.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Mock State for the Prototype
  bool _isDarkMode = false;
  bool _biometricEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Profile Header
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // 2. App Preferences Section
          const Text(
            "PREFERENCES",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: "Dark Mode",
                  icon: Icons.dark_mode_outlined,
                  value: _isDarkMode,
                  onChanged: (val) => setState(() => _isDarkMode = val),
                ),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile(
                  title: "Push Notifications",
                  subtitle: "Receive updates on claims",
                  icon: Icons.notifications_outlined,
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile(
                  title: "Email Digests",
                  subtitle: "Weekly performance summary",
                  icon: Icons.email_outlined,
                  value: _emailNotifications,
                  onChanged: (val) => setState(() => _emailNotifications = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Security Section
          const Text(
            "SECURITY",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: "Biometric Login",
                  subtitle: "FaceID / Fingerprint",
                  icon: Icons.fingerprint,
                  value: _biometricEnabled,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                ),
                const Divider(height: 1, indent: 50),
                _buildActionTile(
                  title: "Change Password",
                  icon: Icons.lock_outline,
                  onTap: () {
                    // TODO: Navigate to Change Password
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Support Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  title: "Help & Support",
                  icon: Icons.help_outline,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 50),
                _buildActionTile(
                  title: "Privacy Policy",
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 5. Logout Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _showLogoutDialog,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              "Version 1.0.0 (Beta)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blueAccent,
              child: Text("E", style: TextStyle(fontSize: 28, color: Colors.white)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.blueAccent),
              ),
            )
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "The Software Engineer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Senior Agent | ID: 882192",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blueAccent),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out of your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.pop(ctx);

              // Navigate to Login Page and remove all previous routes from the stack
              // This prevents the user from pressing "Back" to get into the app again.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}