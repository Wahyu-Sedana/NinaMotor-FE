import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/cores/presentations/widgets/form_widget.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  final ProfileModel profile;

  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;
  late TextEditingController _noTelpController;
  // late TextEditingController _namaKendaraanController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.profile.nama);
    _emailController = TextEditingController(text: widget.profile.email);
    _alamatController =
        TextEditingController(text: widget.profile.alamat ?? '');
    _noTelpController =
        TextEditingController(text: widget.profile.noTelp ?? '');
  // _namaKendaraanController =
    //     TextEditingController(text: widget.profile.namaKendaraan ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    // _noKendaraanController.dispose();
    // _namaKendaraanController.dispose();
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

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = ProfileModel(
        id: widget.profile.id,
        nama: _namaController.text,
        email: _emailController.text,
        role: widget.profile.role,
        emailVerifiedAt: widget.profile.emailVerifiedAt,
        alamat: _alamatController.text,
        noTelp: widget.profile.noTelp,
        profile: widget.profile.profile,
        createdAt: widget.profile.createdAt,
        updatedAt: widget.profile.updatedAt,
      );
      // TODO: Send updatedProfile to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil disimpan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileUrl = widget.profile.profile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (profileUrl != null
                              ? NetworkImage(profileUrl)
                              : null) as ImageProvider<Object>?,
                      backgroundColor: Colors.grey.shade300,
                      child: (profileUrl == null && _imageFile == null)
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              buildTextField(
                controller: _namaController,
                label: 'Nama',
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _emailController,
                label: 'Email',
                enabled: false,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _alamatController,
                label: 'Alamat',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _noTelpController,
                label: 'No Telp',
              ),
              // const SizedBox(height: 16),
              // buildTextField(
              //   controller: _noKendaraanController,
              //   label: 'No Kendaraan',
              // ),
              // const SizedBox(height: 16),
              // buildTextField(
              //   controller: _namaKendaraanController,
              //   label: 'Nama Kendaraan',
              // ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  label: const Text("Simpan",
                      style: TextStyle(fontSize: 16, color: white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
