import 'package:flutter/material.dart';
import 'package:frontend/cores/utils/extension.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';

class ServiceCard extends StatelessWidget {
  final ServisMotorModel data;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon motor di tengah sejajar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.motorcycle,
                size: 28,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            // Informasi utama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.noKendaraan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jenis: ${data.jenisMotor.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Keluhan: ${data.keluhan}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Status chip
            Chip(
              label: Text(data.status),
              backgroundColor: data.status == 'pending'
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: data.status == 'pending'
                    ? Colors.orange.shade800
                    : Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
