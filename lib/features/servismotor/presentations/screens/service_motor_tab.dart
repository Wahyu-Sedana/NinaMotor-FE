import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/extension.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';
import 'package:frontend/features/servismotor/presentations/bloc/event/service_motor_event.dart';
import 'package:frontend/features/servismotor/presentations/bloc/service_motor_bloc.dart';
import 'package:frontend/features/servismotor/presentations/bloc/state/service_motor_state.dart';
import 'package:frontend/features/servismotor/presentations/screens/service_motor_detail_screen.dart';
import 'package:frontend/features/servismotor/presentations/screens/service_motor_pengajuan_screen.dart';

class ServiceMotorTab extends StatefulWidget {
  const ServiceMotorTab({super.key});

  @override
  State<ServiceMotorTab> createState() => _ServiceMotorTabState();
}

class _ServiceMotorTabState extends State<ServiceMotorTab>
    with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadServiceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadServiceData();
    super.didPopNext();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  void _loadServiceData() {
    context.read<MotorServiceBloc>().add(GetMotorServiceEvent());
  }

  List<ServisMotorModel> _filterServices(List<ServisMotorModel> services) {
    var filtered = services.where((service) {
      final matchesSearch = service.noKendaraan
              .toLowerCase()
              .contains(_searchKeyword.toLowerCase()) ||
          service.jenisMotor.label
              .toLowerCase()
              .contains(_searchKeyword.toLowerCase()) ||
          service.keluhan.toLowerCase().contains(_searchKeyword.toLowerCase());

      return matchesSearch;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            _buildServiceStats(),
            Expanded(
              child: BlocBuilder<MotorServiceBloc, MotorServiceState>(
                builder: (context, state) => _buildServiceContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Servis Motor',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: _loadServiceData,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
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
              const Expanded(
                child: Text(
                  'Layanan Servis Motor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola pengajuan servis motor Anda dengan mudah',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan nomor, jenis, atau keluhan...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchKeyword = '');
                      },
                      icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              setState(() => _searchKeyword = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStats() {
    return BlocBuilder<MotorServiceBloc, MotorServiceState>(
      builder: (context, state) {
        if (state is MotorServiceLoadSuccess) {
          final services = state.data.data ?? [];
          final stats = [
            ('Total', '${services.length}', Colors.blue),
            (
              'Pending',
              '${services.where((s) => s.status.toLowerCase() == 'pending').length}',
              Colors.orange
            ),
            (
              'Servis',
              '${services.where((s) => s.status.toLowerCase() == 'in_service').length}',
              Colors.indigo
            ),
            (
              'Priced',
              '${services.where((s) => s.status.toLowerCase() == 'priced').length}',
              Colors.green
            ),
            (
              'Ditolak',
              '${services.where((s) => s.status.toLowerCase() == 'rejected').length}',
              Colors.red
            ),
            (
              'Selesai',
              '${services.where((s) => s.status.toLowerCase() == 'done').length}',
              Colors.purple
            ),
          ];

          return SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _buildStatCard(stat.$1, stat.$2, stat.$3);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:  0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceContent(MotorServiceState state) {
    switch (state.runtimeType) {
      case const (MotorServiceLoading):
        return _buildLoadingState();

      case const (MotorServiceError):
        final errorState = state as MotorServiceError;
        return _buildErrorState(errorState.failure.message);

      case const (MotorServiceLoadSuccess):
        final successState = state as MotorServiceLoadSuccess;
        final services = successState.data.data ?? [];
        final filteredServices = _filterServices(services);

        if (services.isEmpty) {
          return _buildEmptyState();
        }

        if (filteredServices.isEmpty) {
          return _buildSearchEmptyState();
        }

        return _buildServiceList(filteredServices);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data servis...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadServiceData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Pengajuan Servis',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajukan servis motor Anda untuk\nmendapatkan layanan terbaik',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada servis yang cocok dengan\nkriteria pencarian',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchKeyword = '';
              });
            },
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Reset Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList(List<ServisMotorModel> services) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: services.length,
      itemBuilder: (context, index) => _buildServiceCard(services[index]),
    );
  }

  Widget _buildServiceCard(ServisMotorModel service) {
    final statusColor = _getStatusColor(service.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToServiceDetail(service),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(service.status),
                      color: statusColor.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.noKendaraan,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          service.jenisMotor.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.shade200),
                    ),
                    child: Text(
                      service.status,
                      style: TextStyle(
                        color: statusColor.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.keluhan,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(service.createdAt.toString()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Lihat Detail →',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToServiceForm,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Ajukan Servis',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  MaterialColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'done':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_service':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_rounded;
      case 'in_service':
        return Icons.motorcycle_outlined;
      case 'done':
        return Icons.done_all_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tidak diketahui';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hari ini';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Tidak valid';
    }
  }

  void _navigateToServiceForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServicePengajuanScreen()),
    );

    if (result == true) {
      _loadServiceData();
    }
  }

  void _navigateToServiceDetail(ServisMotorModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(serviceData: service),
      ),
    );
  }
}
