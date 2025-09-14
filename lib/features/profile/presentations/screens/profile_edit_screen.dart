import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/presentations/widgets/form_widget.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';
import 'package:frontend/features/profile/presentations/bloc/event/profile_event.dart';
import 'package:frontend/features/profile/presentations/bloc/profile_bloc.dart';
import 'package:frontend/features/profile/presentations/bloc/state/profile_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTelpController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _saveProfile(ProfileModel profile) {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
            UpdateProfileEvent(
              nama: _namaController.text,
              alamat: _alamatController.text,
              noTelp: _noTelpController.text,
              imageProfile: _imageFile?.path,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<ProfileBloc>()..add(GetProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            setState(() => _isLoading = true);
          } else if (state is ProfileLoadSuccess) {
            setState(() => _isLoading = false);
          } else if (state is ProfileError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal: ${state.failure.message}"),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && !_isLoading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (state is ProfileLoadSuccess) {
            final profile = state.profile;

            _namaController.text = profile.nama;
            _emailController.text = profile.email;
            _alamatController.text = profile.alamat ?? '';
            _noTelpController.text = profile.noTelp ?? '';

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.red,
                title: const Text("Edit Profile",
                    style: TextStyle(color: Colors.white)),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isLoading ? null : _pickImage,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (profile.profile != null
                                      ? NetworkImage(
                                          "${AppConfig.baseURLImage}${profile.profile}")
                                      : null) as ImageProvider<Object>?,
                              backgroundColor: Colors.grey.shade300,
                              child: (profile.profile == null &&
                                      _imageFile == null)
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 30),
                          buildTextField(
                              controller: _namaController, label: 'Nama'),
                          const SizedBox(height: 16),
                          buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              enabled: false),
                          const SizedBox(height: 16),
                          buildTextField(
                              controller: _alamatController, label: 'Alamat'),
                          const SizedBox(height: 16),
                          buildTextField(
                              controller: _noTelpController, label: 'No Telp'),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _saveProfile(profile),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text("Simpan",
                                      style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          }

          if (state is ProfileError) {
            return Scaffold(body: Center(child: Text(state.failure.message)));
          }

          return const Scaffold(body: SizedBox());
        },
      ),
    );
  }
}
