import 'package:cloud_firestore/cloud_firestore.dart';

.
class Dormitory {
  final String id;
  final String name;
  final String description; 
  final String rating; 
  final String transport; 
  final String phoneNumber; 
  final String schoolDistanceDetail; 

  final Map<int, int> depositPrices;

  final List<String> imageUrls; 

  final Map<int, int> roomPrices;

  bool isFavorite; 
  final double latitude; 
  final double longitude;
  final List<String> universities; 
  final List<String>
      searchKeywords;

  final String gender; 

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

 
  factory Dormitory.fromSnapshot(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>? ?? {};

    
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }


    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    try {
     
      return Dormitory(
        id: doc.id,
 
        name: data['name']?.toString() ?? 'İsimsiz Yurt',
        description: data['description']?.toString() ?? '',
        rating: data['rating']?.toString() ?? '0.0',
        transport: data['transport']?.toString() ?? '',
        phoneNumber: data['phoneNumber']?.toString() ?? '',
        schoolDistanceDetail: data['schoolDistanceDetail']?.toString() ?? '',

 
        depositPrices: (data['depositPrices'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(toInt(key), toInt(value)),
            ) ??
            {},

        
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
