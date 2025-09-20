import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';
import 'package:frontend/features/home/presentations/screens/produk_detail_screen.dart';
import 'package:frontend/features/home/presentations/widgets/shimmer_widget.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';

class ProdukListScreen extends StatefulWidget {
  const ProdukListScreen({super.key});

  @override
  State<ProdukListScreen> createState() => _ProdukListScreenState();
}

class _ProdukListScreenState extends State<ProdukListScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _searchKeyword = '';
  String _selectedSortBy = 'name';

  final List<Map<String, dynamic>> _sortOptions = [
    {'value': 'name', 'label': 'Nama A-Z', 'icon': Icons.sort_by_alpha_rounded},
    {
      'value': 'price_low',
      'label': 'Harga Terendah',
      'icon': Icons.trending_down_rounded
    },
    {
      'value': 'price_high',
      'label': 'Harga Tertinggi',
      'icon': Icons.trending_up_rounded
    },
    {
      'value': 'stock',
      'label': 'Stok Tersedia',
      'icon': Icons.inventory_rounded
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
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
    _loadProducts();
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

  void _loadProducts() {
    context.read<SparepartBloc>().add(GetAllSparepartsEvent());
  }

  List<SparepartModel> _filterAndSortProducts(List<SparepartModel> products) {
    var filtered = products
        .where((item) =>
            item.nama.toLowerCase().contains(_searchKeyword.toLowerCase()))
        .toList();

    switch (_selectedSortBy) {
      case 'name':
        filtered.sort((a, b) => a.nama.compareTo(b.nama));
        break;
      case 'price_low':
        filtered.sort((a, b) =>
            double.parse(a.hargaJual).compareTo(double.parse(b.hargaJual)));
        break;
      case 'price_high':
        filtered.sort((a, b) =>
            double.parse(b.hargaJual).compareTo(double.parse(a.hargaJual)));
        break;
      case 'stock':
        filtered.sort((a, b) => b.stok.compareTo(a.stok));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildProductStats(),
            Expanded(
              child: BlocBuilder<SparepartBloc, SparepartState>(
                builder: (context, state) => _buildProductContent(state),
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
        'Daftar Produk',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        IconButton(
          onPressed: _loadProducts,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
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
              fillColor: Colors.grey[50],
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.sort_rounded, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Urutkan:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sortOptions.length,
                    itemBuilder: (context, index) {
                      final option = _sortOptions[index];
                      final isSelected = _selectedSortBy == option['value'];

                      return Container(
                        margin: EdgeInsets.only(
                            right: index < _sortOptions.length - 1 ? 8 : 0),
                        child: FilterChip(
                          label: Text(option['label']),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedSortBy = option['value']),
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue.shade50,
                          checkmarkColor: Colors.blue.shade600,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blue.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductStats() {
    return BlocBuilder<SparepartBloc, SparepartState>(
      builder: (context, state) {
        if (state is SparepartLoaded) {
          final filteredProducts = _filterAndSortProducts(state.spareparts);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_rounded,
                    color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  _searchKeyword.isNotEmpty
                      ? '${filteredProducts.length} dari ${state.spareparts.length} produk ditemukan'
                      : '${state.spareparts.length} produk tersedia',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductContent(SparepartState state) {
    switch (state.runtimeType) {
      case const (SparepartLoading):
        return _buildLoadingState();

      case const (SparepartLoaded):
        final loadedState = state as SparepartLoaded;
        final filteredProducts = _filterAndSortProducts(loadedState.spareparts);

        if (loadedState.spareparts.isEmpty) {
          return _buildEmptyState('Belum ada produk tersedia');
        }

        if (filteredProducts.isEmpty && _searchKeyword.isNotEmpty) {
          return _buildSearchEmptyState();
        }

        return RefreshIndicator(
            onRefresh: () async => _loadProducts(),
            child: _buildProductGrid(filteredProducts));

      default:
        return _buildErrorState();
    }
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, __) => shimmerProduk(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Muat Ulang'),
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

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Produk Tidak Ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada produk yang cocok dengan\n"$_searchKeyword"',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchKeyword = '');
            },
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Hapus Pencarian'),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat Produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProducts,
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

  Widget _buildProductGrid(List<SparepartModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, index) =>
          _buildProductCard(products[index], isGrid: true),
    );
  }

  Widget _buildProductCard(SparepartModel product, {required bool isGrid}) {
    return Container(
      margin: isGrid ? null : const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        borderRadius: BorderRadius.circular(16),
        child: isGrid ? _buildGridCard(product) : _buildListCard(product),
      ),
    );
  }

  Widget _buildGridCard(SparepartModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildProductImage(product, height: 140),
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
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                _buildProductInfo(product),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(SparepartModel product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildProductImage(product, width: 80, height: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildProductInfo(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(SparepartModel product,
      {double? width, double? height}) {
    return Hero(
      tag: 'product-${product.kodeSparepart}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                product.gambarProduk.isNotEmpty
                    ? '${AppConfig.baseURLImage}${product.gambarProduk}'
                    : 'https://astraotoshop.com/asset/article-aop/mengatasi-kerusakan-pada-sparepart-motor-matic%20(1)_20240228.webp',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.grey.shade400,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildProductInfo(SparepartModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.kategori?.nama ?? "-",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.inventory_rounded,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${product.stok}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 16, color: Colors.blue.shade600),
          ],
        ),
      ],
    );
  }

  void _navigateToProductDetail(SparepartModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SparepartDetailScreen(sparepart: product),
      ),
    );
  }
}
