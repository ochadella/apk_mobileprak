import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(
                  radius: 42,
                  child: Icon(Icons.person, size: 42),
                ),
                SizedBox(height: 16),
                Text(
                  "Admin D4TI",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text("admin@kampus.ac.id"),
                SizedBox(height: 4),
                Text("Dashboard Modul 4"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}