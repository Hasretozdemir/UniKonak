import 'package:cloud_firestore/cloud_firestore.dart';

class CityFilter {
  final String city;
  final List<String> universities;

  CityFilter(this.city, this.universities);


  factory CityFilter.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CityFilter(
      data['name'] ?? '',
      List<String>.from(data['universities'] ?? []),
    );
  }
}


class PriceRange {
  final double minPrice;
  final double maxPrice;
  PriceRange(this.minPrice, this.maxPrice);
}
