import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/enum.dart';
import 'package:frontend/features/servismotor/presentations/bloc/event/service_motor_event.dart';
import 'package:frontend/features/servismotor/presentations/bloc/service_motor_bloc.dart';
import 'package:frontend/features/servismotor/presentations/bloc/state/service_motor_state.dart';

class ServicePengajuanScreen extends StatefulWidget {
  const ServicePengajuanScreen({super.key});

  @override
  State<ServicePengajuanScreen> createState() => _ServicePengajuanScreenState();
}

class _ServicePengajuanScreenState extends State<ServicePengajuanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noKendaraanController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();
  JenisMotor? selectedMotorType;

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate() && selectedMotorType != null) {
      context.read<MotorServiceBloc>().add(
            SubmitMotorServiceEvent(
              noKendaraan: _noKendaraanController.text,
              keluhan: _keluhanController.text,
              jenisMotor: selectedMotorType!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Servis Motor')),
      body: BlocListener<MotorServiceBloc, MotorServiceState>(
        listener: (context, state) {
          if (state is MotorServiceSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is MotorServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: ${state.failure.message}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _noKendaraanController,
                  decoration: const InputDecoration(
                    labelText: 'No Kendaraan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'No kendaraan wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<JenisMotor>(
                  value: selectedMotorType,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Motor',
                    border: OutlineInputBorder(),
                  ),
                  items: JenisMotor.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedMotorType = value);
                  },
                  validator: (v) => v == null ? 'Pilih jenis motor' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _keluhanController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Keluhan / Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Keluhan wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<MotorServiceBloc, MotorServiceState>(
                  builder: (context, state) {
                    final isLoading = state is MotorServiceLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _submit(context),
                        icon: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: white,
                              ),
                        label: const Text('Kirim Pengajuan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
