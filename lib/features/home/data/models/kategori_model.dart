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
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
    };
  }
}
