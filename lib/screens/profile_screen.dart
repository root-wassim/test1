import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../config/theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.getAppUser();
    if (mounted) setState(() { _user = user; _loading = false; });
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: AppTheme.accent))),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.logout();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));

    final user = _user;
    if (user == null) return const Center(child: Text('No user data', style: TextStyle(color: Colors.white54)));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: Column(children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)],
                ),
                child: Center(
                  child: Text(
                    '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('Age ${user.age}', style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
            ]),
          ),

          const SizedBox(height: 32),

          // Info cards
          _infoTile(Icons.person_outline, 'First Name', user.firstName),
          _infoTile(Icons.person_outline, 'Last Name', user.lastName),
          _infoTile(Icons.email_outlined, 'Email', user.email),
          _infoTile(Icons.cake_outlined, 'Date of Birth', DateFormat('MMM dd, yyyy').format(user.birthDate)),
          _infoTile(Icons.calendar_today_outlined, 'Member Since', DateFormat('MMM yyyy').format(user.createdAt)),

          const SizedBox(height: 32),

          // Sign out
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: AppTheme.accent),
              label: const Text('Sign Out', style: TextStyle(color: AppTheme.accent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}
