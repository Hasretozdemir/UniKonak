import 'package:cloud_firestore/cloud_firestore.dart';

class CityFilter {
  final String city;
  final List<String> universities;

  CityFilter(this.city, this.universities);

  // Firebase'den gelen veriyi modele çeviren fonksiyon
  factory CityFilter.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CityFilter(
      data['name'] ?? '', // Veritabanında şehir adı 'name' alanında olacak
      List<String>.from(data['universities'] ?? []),
    );
  }
}

// PriceRange sınıfı aynı kalabilir, o veritabanından gelmese de olur.
class PriceRange {
  final double minPrice;
  final double maxPrice;
  PriceRange(this.minPrice, this.maxPrice);
}
