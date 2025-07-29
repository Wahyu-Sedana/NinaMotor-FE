import 'kategori_model.dart';

class SparepartModel {
  final String kodeSparepart;
  final String nama;
  final String? deskripsi;
  int stok;
  final String hargaBeli;
  final String hargaJual;
  final String merk;
  final String gambarProduk;
  final KategoriModel? kategori;

  SparepartModel({
    required this.kodeSparepart,
    required this.nama,
    this.deskripsi,
    required this.stok,
    required this.hargaBeli,
    required this.hargaJual,
    required this.merk,
    required this.gambarProduk,
    this.kategori,
  });

  factory SparepartModel.fromJson(Map<String, dynamic> json) {
    return SparepartModel(
      kodeSparepart: json['kode_sparepart'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      stok: json['stok'] ?? 0,
      hargaBeli: json['harga_beli'] ?? 0,
      hargaJual: json['harga_jual'] ?? 0,
      merk: json['merk'] ?? '',
      gambarProduk: json['gambar_produk'],
      kategori: json['kategori'] != null
          ? KategoriModel.fromJson(json['kategori'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_sparepart': kodeSparepart,
      'nama': nama,
      'deskripsi': deskripsi,
      'stok': stok,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'merk': merk,
      'gambar_produk': gambarProduk,
      'kategori': kategori?.toJson(),
    };
  }
}
