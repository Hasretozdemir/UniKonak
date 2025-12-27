import 'package:cloud_firestore/cloud_firestore.dart';

// YURT MODELİ SINIFI
// Veritabanındaki (Firebase Firestore) 'yurtlar' koleksiyonundaki verileri
// uygulama içinde kullanabileceğimiz Dart nesnelerine dönüştüren modeldir.
class Dormitory {
  final String id; // Veritabanındaki benzersiz belge ID'si
  final String name; // Yurdun adı
  final String description; // Yurt hakkındaki açıklama yazısı
  final String rating; // Yurt puanı (Örn: "4.5/5")
  final String transport; // Ulaşım bilgisi (Örn: "Metroya 5 dk")
  final String phoneNumber; // İletişim numarası
  final String schoolDistanceDetail; // Okula uzaklık ile ilgili detaylı bilgi

  // Depozito Fiyatları: Kaç kişilik oda (key) -> Fiyat (value)
  // Örn: {1: 10000} -> 1 kişilik oda depozitosu 10 bin TL
  final Map<int, int> depositPrices;

  final List<String> imageUrls; // Yurt fotoğraflarının URL listesi

  // Oda Fiyatları: Kaç kişilik oda (key) -> Aylık Ücret (value)
  final Map<int, int> roomPrices;

  bool isFavorite; // Kullanıcının favorilerinde ekli mi?
  final double latitude; // Harita konumu (Enlem)
  final double longitude; // Harita konumu (Boylam)
  final List<String> universities; // Yurdun yakın olduğu üniversiteler
  final List<String>
      searchKeywords; // Arama yaparken kullanılacak anahtar kelimeler

  final String gender; // Yurt türü (Kız/Erkek)

  // Kurucu Metot (Constructor)
  Dormitory({
    this.id = '',
    required this.name,
    required this.description,
    required this.rating,
    required this.transport,
    required this.phoneNumber,
    required this.schoolDistanceDetail,
    required this.depositPrices,
    required this.imageUrls,
    required this.roomPrices,
    this.isFavorite = false,
    required this.latitude,
    required this.longitude,
    required this.universities,
    required this.searchKeywords,
    required this.gender,
  });

  // FIREBASE DÖNÜŞTÜRÜCÜSÜ (Factory Constructor)
  // Firestore'dan gelen belgeyi (DocumentSnapshot) alıp Dormitory nesnesine çevirir.
  factory Dormitory.fromSnapshot(DocumentSnapshot doc) {
    // Veri null gelirse boş bir harita ({}) kullanır.
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // YARDIMCI FONKSİYON: INT ÇEVİRİCİ
    // Veritabanından gelen sayı bazen String ("5000"), bazen Double (5000.0) olabilir.
    // Bu fonksiyon her türlü veriyi güvenli bir şekilde tamsayıya (int) çevirir.
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // YARDIMCI FONKSİYON: DOUBLE ÇEVİRİCİ
    // Koordinatlar için gelen veriyi güvenli bir şekilde ondalıklı sayıya (double) çevirir.
    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    try {
      // Verileri eşleştirip nesneyi oluşturuyoruz
      return Dormitory(
        id: doc.id,
        // ?? operatörü ile veri null gelirse varsayılan değer atıyoruz
        name: data['name']?.toString() ?? 'İsimsiz Yurt',
        description: data['description']?.toString() ?? '',
        rating: data['rating']?.toString() ?? '0.0',
        transport: data['transport']?.toString() ?? '',
        phoneNumber: data['phoneNumber']?.toString() ?? '',
        schoolDistanceDetail: data['schoolDistanceDetail']?.toString() ?? '',

        // Map yapılarını (Fiyatlar) güvenli şekilde dönüştürme işlemi
        depositPrices: (data['depositPrices'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(toInt(key), toInt(value)),
            ) ??
            {},

        // Resim listesini veya varsa yerel asset listesini alma
        imageUrls:
            List<String>.from(data['imageUrls'] ?? data['imageAsset'] ?? []),

        roomPrices: (data['roomPrices'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(toInt(key), toInt(value)),
            ) ??
            {},

        isFavorite: data['isFavorite'] ?? false,
        latitude: toDouble(data['latitude']),
        longitude: toDouble(data['longitude']),
        universities: List<String>.from(data['universities'] ?? []),
        searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
        gender: data['gender']?.toString() ?? 'Kız',
      );
    } catch (e) {
      // HATA YÖNETİMİ
      // Eğer veritabanındaki bir veri bozuksa veya eksikse uygulama çökmesin diye
      // konsola hata basar ve "Hatalı Veri" isimli geçici bir nesne döndürür.
      print("HATA: '${doc.id}' ID'li yurt verisi çekilemedi!");
      print("Hata Detayı: $e");

      return Dormitory(
        id: doc.id,
        name: "Hatalı Veri (${doc.id})",
        description: "Bu veri çekilirken hata oluştu.",
        rating: "0",
        transport: "",
        phoneNumber: "",
        schoolDistanceDetail: "",
        depositPrices: {},
        imageUrls: [],
        roomPrices: {},
        latitude: 0,
        longitude: 0,
        universities: [],
        searchKeywords: [],
        gender: 'Kız',
      );
    }
  }
}
