class KategoriModel {
  final int id;
  final String nama;
  final String? deskripsi;

  KategoriModel({
    required this.id,
    required this.nama,
    this.deskripsi,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'],
      nama: json['nama_kategori'] ?? '',
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kategori': nama,
      'deskripsi': deskripsi,
    };
  }
}
