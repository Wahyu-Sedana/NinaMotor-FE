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

class _ServicePengajuanScreenState extends State<ServicePengajuanScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noKendaraanController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();

  JenisMotor? _selectedMotorType;

  @override
  void dispose() {
    _noKendaraanController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedMotorType != null) {
      context.read<MotorServiceBloc>().add(
            SubmitMotorServiceEvent(
              noKendaraan: _noKendaraanController.text.trim(),
              keluhan: _keluhanController.text.trim(),
              jenisMotor: _selectedMotorType!,
            ),
          );
    } else if (_selectedMotorType == null) {
      _showErrorSnackBar('Silakan pilih jenis motor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: BlocListener<MotorServiceBloc, MotorServiceState>(
        listener: _handleBlocState,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Pengajuan Servis Motor',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildForm(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Servis Motor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajukan servis untuk motor Anda dengan mengisi form di bawah ini',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Kendaraan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildNoKendaraanField(),
            const SizedBox(height: 20),
            _buildJenisMotorDropdown(),
            const SizedBox(height: 24),
            const Text(
              'Detail Keluhan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildKeluhanField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoKendaraanField() {
    return TextFormField(
      controller: _noKendaraanController,
      decoration: InputDecoration(
        labelText: 'Nomor Kendaraan',
        hintText: 'Contoh: B1234ABC',
        prefixIcon: const Icon(Icons.motorcycle_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nomor kendaraan wajib diisi';
        }
        if (value.trim().length < 3) {
          return 'Nomor kendaraan minimal 3 karakter';
        }
        return null;
      },
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildJenisMotorDropdown() {
    return DropdownButtonFormField<JenisMotor>(
      value: _selectedMotorType,
      decoration: InputDecoration(
        labelText: 'Jenis Motor',
        hintText: 'Pilih jenis motor',
        prefixIcon: const Icon(Icons.two_wheeler_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: JenisMotor.values.map((type) {
        return DropdownMenuItem<JenisMotor>(
          value: type,
          child: Row(
            children: [
              Icon(_getMotorIcon(type), size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(type.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedMotorType = value);
      },
      validator: (value) {
        if (value == null) {
          return 'Pilih jenis motor';
        }
        return null;
      },
    );
  }

  IconData _getMotorIcon(JenisMotor type) {
    switch (type) {
      case JenisMotor.matic:
        return Icons.electric_scooter_rounded;
      case JenisMotor.manual:
        return Icons.motorcycle_rounded;
    }
  }

  Widget _buildKeluhanField() {
    return TextFormField(
      controller: _keluhanController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Keluhan / Deskripsi Masalah',
        hintText: 'Jelaskan masalah atau keluhan pada motor Anda...',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.description_rounded),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Keluhan wajib diisi';
        }
        if (value.trim().length < 10) {
          return 'Jelaskan keluhan minimal 10 karakter';
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<MotorServiceBloc, MotorServiceState>(
      builder: (context, state) {
        final isLoading = state is MotorServiceLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kirim Pengajuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _handleBlocState(BuildContext context, MotorServiceState state) {
    switch (state.runtimeType) {
      case const (MotorServiceSubmitSuccess):
        final successState = state as MotorServiceSubmitSuccess;
        _showSuccessSnackBar(successState.message);
        Navigator.pop(context);
        break;

      case const (MotorServiceError):
        final errorState = state as MotorServiceError;
        _showErrorSnackBar('Gagal: ${errorState.failure.message}');
        break;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
