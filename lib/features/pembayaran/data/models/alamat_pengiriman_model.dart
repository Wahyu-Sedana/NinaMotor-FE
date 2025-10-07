class AlamatPengiriman {
  final String id;
  final String userId;
  final String labelAlamat;
  final String namaPenerima;
  final String noTelpPenerima;
  final double latitude;
  final double longitude;
  final String alamatLengkap;
  final int provinceId;
  final String provinceName;
  final int cityId;
  final String cityName;
  final String? kodePos;
  final bool isDefault;

  AlamatPengiriman({
    required this.id,
    required this.userId,
    required this.labelAlamat,
    required this.namaPenerima,
    required this.noTelpPenerima,
    required this.latitude,
    required this.longitude,
    required this.alamatLengkap,
    required this.provinceId,
    required this.provinceName,
    required this.cityId,
    required this.cityName,
    this.kodePos,
    this.isDefault = false,
  });

  factory AlamatPengiriman.fromJson(Map<String, dynamic> json) {
    return AlamatPengiriman(
      id: json['id'],
      userId: json['user_id'],
      labelAlamat: json['label_alamat'],
      namaPenerima: json['nama_penerima'],
      noTelpPenerima: json['no_telp_penerima'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      alamatLengkap: json['alamat_lengkap'],
      provinceId: json['province_id'],
      provinceName: json['province_name'],
      cityId: json['city_id'],
      cityName: json['city_name'],
      kodePos: json['kode_pos'],
      isDefault: json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label_alamat': labelAlamat,
      'nama_penerima': namaPenerima,
      'no_telp_penerima': noTelpPenerima,
      'latitude': latitude,
      'longitude': longitude,
      'alamat_lengkap': alamatLengkap,
      'province_id': provinceId,
      'province_name': provinceName,
      'city_id': cityId,
      'city_name': cityName,
      'kode_pos': kodePos,
      'is_default': isDefault ? 1 : 0,
    };
  }
}

class OngkirResult {
  final String service;
  final String description;
  final int cost;
  final String etd;

  OngkirResult({
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
  });

  factory OngkirResult.fromJson(Map<String, dynamic> json) {
    return OngkirResult(
      service: json['service'],
      description: json['description'],
      cost: json['cost'][0]['value'],
      etd: json['cost'][0]['etd'],
    );
  }
}
