import 'package:flutter/material.dart';

class ServiceMotorTab extends StatefulWidget {
  const ServiceMotorTab({super.key});

  @override
  State<ServiceMotorTab> createState() => _ServiceMotorTabState();
}

class _ServiceMotorTabState extends State<ServiceMotorTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _motorYearController = TextEditingController();

  final List<String> motorTypes = ['Matic', 'Manual'];
  String? selectedMotorType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Service Motor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Form Pengajuan Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Card(
              color: Color(0xFFFEF3C7),
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading:
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text(
                  'Pastikan data yang dimasukkan benar. Admin akan menghubungi Anda setelah data diverifikasi.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _serviceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Service',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama service wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi/Keluhan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Deskripsi wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Jenis Motor',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMotorType,
                    items: motorTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedMotorType = value);
                    },
                    validator: (value) =>
                        value == null ? 'Pilih jenis motor' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _motorYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Motor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Tahun motor wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Pengajuan'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                      child:
                                          Text('Pengajuan berhasil dikirim')),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Panggil API di sini
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
