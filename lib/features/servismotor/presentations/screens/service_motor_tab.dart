import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/extension.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';
import 'package:frontend/features/servismotor/presentations/bloc/event/service_motor_event.dart';
import 'package:frontend/features/servismotor/presentations/bloc/service_motor_bloc.dart';
import 'package:frontend/features/servismotor/presentations/bloc/state/service_motor_state.dart';
import 'package:frontend/features/servismotor/presentations/screens/service_motor_pengajuan_screen.dart';
import 'package:frontend/features/servismotor/presentations/widgets/service_card_widget.dart';
import 'package:frontend/features/servismotor/presentations/screens/service_motor_list_screen.dart';

class ServiceMotorTab extends StatefulWidget {
  const ServiceMotorTab({super.key});

  @override
  State<ServiceMotorTab> createState() => _ServiceMotorTabState();
}

class _ServiceMotorTabState extends State<ServiceMotorTab> {
  String searchKeyword = '';
  @override
  void initState() {
    super.initState();
    context.read<MotorServiceBloc>().add(GetMotorServiceEvent());
  }

  void _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServicePengajuanScreen()),
    );

    if (result == true) {
      context.read<MotorServiceBloc>().add(GetMotorServiceEvent());
    }
  }

  void _goToDetail(ServisMotorModel data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(serviceData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servis Motor')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: redColor,
        heroTag: 'fablist',
        onPressed: _navigateToForm,
        icon: const Icon(Icons.add, color: white),
        label: const Text('Ajukan Servis', style: TextStyle(color: white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari No. Kendaraan / Jenis / Keluhan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MotorServiceBloc, MotorServiceState>(
                builder: (context, state) {
                  if (state is MotorServiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MotorServiceLoadSuccess) {
                    final filtered = state.data.data!
                        .where((item) =>
                            item.noKendaraan
                                .toLowerCase()
                                .contains(searchKeyword.toLowerCase()) ||
                            item.jenisMotor.label
                                .toLowerCase()
                                .contains(searchKeyword.toLowerCase()))
                        .toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text("Data tidak ditemukan."));
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ServiceCard(
                          data: item,
                          onTap: () => _goToDetail(item),
                        );
                      },
                    );
                  } else if (state is MotorServiceError) {
                    return Center(
                      child:
                          Text('Gagal memuat data: ${state.failure.message}'),
                    );
                  }
                  return const SizedBox(); // Default state
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
