import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/helper.dart';
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
  String? selectedKategori;

  @override
  void didPopNext() {
    if (selectedKategori != null) {
      context
          .read<SparepartBloc>()
          .add(GetSparepartByKategoriEvent(namaKategori: selectedKategori!));
    } else {
      context.read<SparepartBloc>().add(GetAllSparepartsEvent());
    }
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    context.read<KategoriBloc>().add(GetAllKategoriEvent());
    context.read<SparepartBloc>().add(GetAllSparepartsEvent());
    super.initState();
  }

  void _onKategoriSelected(String namaKategori) {
    setState(() {
      selectedKategori = selectedKategori == namaKategori ? null : namaKategori;
    });

    if (selectedKategori != null) {
      context
          .read<SparepartBloc>()
          .add(GetSparepartByKategoriEvent(namaKategori: selectedKategori!));
    } else {
      context.read<SparepartBloc>().add(GetAllSparepartsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    "Selamat Datang \nDi Bengkel Nina Motor!",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.notifications_none, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari item...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                // Optional: implement local search filter
              },
            ),
            const SizedBox(height: 24),

            // Kategori Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Kategori Produk",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteService.listProdukRoute);
                  },
                  child: const Text(
                    "Lihat Semua",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            BlocBuilder<KategoriBloc, KategoriState>(
              builder: (context, state) {
                if (state is KategoriLoading) {
                  return SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        return shimmerKategori();
                      },
                    ),
                  );
                } else if (state is KategoriLoaded) {
                  return SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.kategoriList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final KategoriModel kategori =
                            state.kategoriList[index];
                        final isSelected = selectedKategori == kategori.nama;

                        return GestureDetector(
                          onTap: () => _onKategoriSelected(kategori.nama),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey.shade200,
                              border: isSelected
                                  ? Border.all(color: Colors.red, width: 2)
                                  : null,
                            ),
                            child: Text(
                              kategori.nama,
                              style: TextStyle(
                                color: isSelected ? white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Text("Gagal memuat kategori");
                }
              },
            ),
            const SizedBox(height: 24),

            // Produk Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedKategori != null
                      ? "Produk $selectedKategori"
                      : "Semua Produk",
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            BlocBuilder<SparepartBloc, SparepartState>(
              builder: (context, state) {
                if (state is SparepartLoading) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (_, index) => shimmerProduk(),
                  );
                } else if (state is SparepartLoaded) {
                  if (state.spareparts.isEmpty) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            "Tidak ada produk ditemukan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.spareparts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (_, index) {
                        final SparepartModel item = state.spareparts[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16)),
                                      child: item.gambarProduk.isNotEmpty
                                          ? Image.network(
                                              '$baseURLImage${item.gambarProduk}',
                                              height: 140,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              'https://astraotoshop.com/asset/article-aop/mengatasi-kerusakan-pada-sparepart-motor-matic%20(1)_20240228.webp',
                                              height: 140,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        formatIDR(double.parse(item.hargaJual)),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nama,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.kategori?.nama ?? "-",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Stok: ${item.stok}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SparepartDetailScreen(
                                                    sparepart: item),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Selengkapnya →",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                } else if (state is SparepartError) {
                  return Center(
                    child: const Text(
                      "Tidak ada produk ditemukan",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
