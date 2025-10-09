import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/strings.dart';
import 'package:frontend/features/home/data/models/kategori_model.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';
import 'package:frontend/features/home/presentations/bloc/event/kategori_event.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/kategori_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/kategori_state.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';
import 'package:frontend/features/home/presentations/screens/produk_detail_screen.dart';
import 'package:frontend/features/home/presentations/widgets/shimmer_widget.dart';
import 'package:frontend/features/routes/route.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with RouteAware {
  String? _selectedKategori;
  late PageController _pageController;
  int _currentPage = 0;
  int _notifCount = 0;
  final List<String> _messages = [];

  static const List<String> _sliderImages = [
    imageSlide1,
    imageSlide2,
    imageSlide3,
  ];

  static const List<Map<String, String>> _sliderData = [
    {
      'title': 'Sparepart Berkualitas',
      'subtitle': 'Harga terjangkau, kualitas terjamin'
    },
    {
      'title': 'Service Terpercaya',
      'subtitle': 'Pelayanan profesional untuk kendaraan Anda'
    },
    {
      'title': 'Aplikasi Nina Motor',
      'subtitle': 'Kemudahan berbelanja di genggaman'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeData();
    _setupFirebaseMessaging();
    _startAutoSlider();
  }

  @override
  void dispose() {
    _pageController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _refreshProducts();
    super.didPopNext();
  }

  void _initializeData() {
    context.read<KategoriBloc>().add(GetAllKategoriEvent());
    context.read<SparepartBloc>().add(GetAllSparepartsEvent());
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        setState(() {
          _notifCount++;
          _messages.add(message.notification?.body ?? "Pesan baru");
        });
      }
    });
  }

  void _startAutoSlider() {
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;

    setState(() {
      _currentPage = (_currentPage + 1) % _sliderImages.length;
    });

    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  void _refreshProducts() {
    if (_selectedKategori != null) {
      context
          .read<SparepartBloc>()
          .add(GetSparepartByKategoriEvent(namaKategori: _selectedKategori!));
    } else {
      context.read<SparepartBloc>().add(GetAllSparepartsEvent());
    }
  }

  void _onKategoriTap(String namaKategori) {
    setState(() {
      _selectedKategori =
          _selectedKategori == namaKategori ? null : namaKategori;
    });
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _initializeData(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildHeroSlider(),
              const SizedBox(height: 32),
              _buildKategoriSection(),
              const SizedBox(height: 24),
              _buildProdukSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                'Nina Motor',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _showNotificationDialog,
            icon: const Icon(Icons.notifications_outlined),
            color: Colors.grey[700],
            padding: const EdgeInsets.all(12),
          ),
        ),
        if (_notifCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                '$_notifCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSlider() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        itemCount: _sliderImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _sliderImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sliderData[index]['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _sliderData[index]['subtitle']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKategoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteService.listProdukRoute),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<KategoriBloc, KategoriState>(
          builder: (context, state) {
            if (state is KategoriLoading) {
              return _buildKategoriShimmer();
            }
            if (state is KategoriLoaded) {
              return _buildKategoriList(state.kategoriList);
            }
            return const Text("Gagal memuat kategori");
          },
        ),
      ],
    );
  }

  Widget _buildKategoriList(List<KategoriModel> categories) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final kategori = categories[index];
          final isSelected = _selectedKategori == kategori.nama;

          return GestureDetector(
            onTap: () => _onKategoriTap(kategori.nama),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: isSelected ? Colors.blue : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                kategori.nama,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKategoriShimmer() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => shimmerKategori(),
      ),
    );
  }

  Widget _buildProdukSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedKategori != null
              ? 'Produk $_selectedKategori'
              : 'Semua Produk',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<SparepartBloc, SparepartState>(
          builder: (context, state) {
            if (state is SparepartLoading) {
              return _buildProdukGrid(isLoading: true);
            }
            if (_selectedKategori != null) {
              if (state is KategoriSparepartLoaded) {
                if (state.sparepartsByKategori.spareparts.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildProdukGrid(
                    products: state.sparepartsByKategori.spareparts);
              }
            } else {
              if (state is SparepartLoaded) {
                if (state.spareparts.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildProdukGrid(products: state.spareparts);
              }
            }
            if (state is SparepartError) {
              return _buildErrorState();
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildProdukGrid(
      {List<SparepartModel>? products, bool isLoading = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: isLoading ? 6 : products?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, index) {
        if (isLoading) return shimmerProduk();

        final product = products![index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(SparepartModel product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SparepartDetailScreen(sparepart: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.gambarProduk.isNotEmpty
                          ? '${AppConfig.baseURLImage}${product.gambarProduk}'
                          : 'https://astraotoshop.com/asset/article-aop/mengatasi-kerusakan-pada-sparepart-motor-matic%20(1)_20240228.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formatIDR(double.parse(product.hargaJual)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.kategori?.nama ?? "-",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Stok: ${product.stok}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "Tidak ada produk ditemukan",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ));
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            "Gagal memuat produk",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _initializeData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                width: double.infinity,
                child: const Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: _messages.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Tidak ada notifikasi",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) => ListTile(
                          leading: const Icon(Icons.notifications,
                              color: Colors.blue),
                          title: Text(_messages[index]),
                        ),
                      ),
              ),
              if (_messages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _messages.clear();
                          _notifCount = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Tandai semua dibaca"),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
