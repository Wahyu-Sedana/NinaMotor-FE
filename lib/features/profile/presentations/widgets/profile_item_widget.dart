import 'package:flutter/material.dart';

Widget buildProfileItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.red),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
      const Divider(height: 1),
    ],
  );
}
