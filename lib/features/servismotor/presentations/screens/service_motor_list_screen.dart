import 'package:flutter/material.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServisMotorModel serviceData;

  const ServiceDetailScreen({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengajuan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No Kendaraan: ${serviceData.noKendaraan}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Jenis Motor: ${serviceData.jenisMotor}'),
                const SizedBox(height: 8),
                Text('Keluhan: ${serviceData.keluhan}'),
                const SizedBox(height: 8),
                Text(
                  'Status: ${serviceData.status}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: serviceData.status == 'Pending'
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
