import 'package:flutter/material.dart';
import 'package:frontend/cores/utils/extension.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServisMotorModel serviceData;

  const ServiceDetailScreen({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Pengajuan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItem("No Kendaraan", serviceData.noKendaraan),
                    const Divider(height: 24),
                    _buildItem("Jenis Motor", serviceData.jenisMotor.label),
                    const Divider(height: 24),
                    _buildItem("Keluhan", serviceData.keluhan),
                    const Divider(height: 24),
                    _buildItem(
                      "Status",
                      serviceData.status,
                      valueColor: serviceData.status == 'Pending'
                          ? Colors.orange
                          : Colors.green,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value,
      {bool isBold = false, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
