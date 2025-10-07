import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/cores/services/rajaongkir_service.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _session = locator<Session>();
  final _rajaOngkirService = RajaOngkirService();

  // Form Controllers
  final _labelAlamatController = TextEditingController();
  final _namaPenerimaController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _kodePosController = TextEditingController();

  // Dropdown Data
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _districts = [];

  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedCity;
  Map<String, dynamic>? _selectedDistrict;

  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingCities = false;
  bool _isSaving = false;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _labelAlamatController.dispose();
    _namaPenerimaController.dispose();
    _noTelpController.dispose();
    _alamatLengkapController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  // ==================== RAJAONGKIR METHODS ====================

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);

    try {
      final provinces = await _rajaOngkirService.getProvinces();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });
    } catch (e) {
      setState(() => _isLoadingProvinces = false);
      print(e);
      _showErrorSnackBar('Gagal memuat provinsi: $e');
    }
  }

  Future<void> _loadDistricts(int cityId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });

    try {
      final districts = await _rajaOngkirService.getDistrict(cityId);
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() => _isLoadingDistricts = false);
      _showErrorSnackBar('Gagal memuat kecamatan: $e');
    }
  }

  Future<void> _loadCities(int provinceId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
    });

    try {
      final cities = await _rajaOngkirService.getCities(provinceId);
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() => _isLoadingCities = false);
      _showErrorSnackBar('Gagal memuat kota: $e');
    }
  }

  // ==================== SAVE ADDRESS ====================

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvince == null || _selectedCity == null) {
      _showErrorSnackBar('Silakan pilih provinsi dan kota');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dio = Dio();
      final response = await dio.post(
        '${AppConfig.baseURL}alamat',
        data: {
          'user_id': _session.getIdUser,
          'label_alamat': _labelAlamatController.text,
          'nama_penerima': _namaPenerimaController.text,
          'no_telp_penerima': _noTelpController.text,
          'alamat_lengkap': _alamatLengkapController.text,
          'province_id': _selectedProvince?['province_id'] ?? '',
          'province_name': _selectedProvince?['province'] ?? '',
          'city_id': _selectedCity?['city_id'] ?? '',
          'city_name': _selectedCity?['city_name'] ?? '',
          'district_id': _selectedDistrict?['district_id'] ?? '',
          'district_name': _selectedDistrict?['district_name'] ?? '',
          'kode_pos': _kodePosController.text,
          'is_default': _isDefault ? 1 : 0,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      print(response.data);

      if (response.data['success'] == true) {
        if (mounted) {
          Navigator.pop(context, true);
          _showSuccessSnackBar('Alamat berhasil ditambahkan');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan alamat');
      }
    } on DioException catch (e) {
      String errorMessage = 'Gagal menyimpan alamat';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first.first ?? errorMessage;
        }
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Tambah Alamat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // ==================== FORM SECTION ====================

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_location_alt_rounded,
                  color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Detail Alamat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Label Alamat
          _buildTextField(
            controller: _labelAlamatController,
            label: 'Label Alamat',
            hint: 'Rumah, Kantor, Kos, dll',
            icon: Icons.label_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Label alamat wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Nama Penerima
          _buildTextField(
            controller: _namaPenerimaController,
            label: 'Nama Penerima',
            hint: 'Nama lengkap penerima',
            icon: Icons.person_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama penerima wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // No Telepon
          _buildTextField(
            controller: _noTelpController,
            label: 'No. Telepon',
            hint: '08123456789',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'No. telepon wajib diisi';
              }
              if (value.length < 10) {
                return 'No. telepon tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Province Dropdown
          _buildDropdown(
            label: 'Provinsi',
            icon: Icons.map_rounded,
            value: _selectedProvince,
            items: _provinces,
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _selectedCity = null;
              });
              if (value != null) {
                _loadCities(value['province_id']);
              }
            },
            itemLabel: (item) => item['province'],
            isLoading: _isLoadingProvinces,
          ),
          const SizedBox(height: 16),

          // City Dropdown
          _buildDropdown(
            label: 'Kota',
            icon: Icons.location_city_rounded,
            value: _selectedCity,
            items: _cities,
            onChanged: (value) {
              setState(() => _selectedCity = value);
              if (value != null) {
                _loadDistricts(value['city_id']);
              }
            },
            itemLabel: (item) => item['city_name'] ?? 'Tidak ada nama',
            isLoading: _isLoadingCities,
            enabled: _selectedProvince != null,
          ),
          const SizedBox(height: 16),

          _buildDropdown(
            label: 'Kecamatan',
            icon: Icons.location_city_rounded,
            value: _selectedDistrict,
            items: _districts,
            onChanged: (value) {
              setState(() => _selectedDistrict = value);
            },
            itemLabel: (item) => item['district_name'] ?? 'Tidak ada nama',
            isLoading: _isLoadingDistricts,
            enabled: _selectedCity != null,
          ),
          const SizedBox(height: 16),

          // Alamat Lengkap
          _buildTextField(
            controller: _alamatLengkapController,
            label: 'Alamat Lengkap',
            hint: 'Nama jalan, no rumah, RT/RW, patokan',
            icon: Icons.home_rounded,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Alamat lengkap wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Kode Pos
          _buildTextField(
            controller: _kodePosController,
            label: 'Kode Pos',
            hint: '80361',
            icon: Icons.mail_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Set as Default
          InkWell(
            onTap: () => setState(() => _isDefault = !_isDefault),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDefault ? Colors.blue.shade50 : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _isDefault ? Colors.blue.shade300 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isDefault
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: _isDefault ? Colors.blue.shade600 : Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Jadikan alamat utama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required void Function(Map<String, dynamic>?) onChanged,
    required String Function(Map<String, dynamic>) itemLabel,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.grey[50] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: items.contains(value) ? value : null,
                    isExpanded: true,
                    hint: Text(
                      'Pilih $label',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(itemLabel(item)),
                        ),
                      );
                    }).toList(),
                    onChanged: enabled ? onChanged : null,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ),
        ),
      ],
    );
  }

  // ==================== BOTTOM BUTTON ====================

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: _isSaving
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
                      Icon(Icons.save_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Alamat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ==================== SNACKBARS ====================

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
