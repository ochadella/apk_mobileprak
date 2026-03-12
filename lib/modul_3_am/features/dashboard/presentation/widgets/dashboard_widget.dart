import 'package:flutter/material.dart';
import '../../data/models/dashboard_model.dart';

class DashboardItem extends StatelessWidget {
  final DashboardStats stats;
  final VoidCallback onTap;

  const DashboardItem({
    super.key,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(stats.title, style: const TextStyle(fontSize: 16)),
            Text(
              'Total: ${stats.value}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}