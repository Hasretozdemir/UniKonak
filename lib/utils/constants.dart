import 'package:flutter/material.dart';
import '../models/filter_models.dart'; // PriceRange modelini tanuması için

class AppConstants {
  static const Color primaryBackgroundColor = Color.fromARGB(255, 4, 23, 36);
  static const Color accentColor = Color.fromARGB(255, 13, 75, 79);
  static const Color priceColor = Color.fromARGB(255, 4, 2, 28);

  // --- DUMMY_DATA'DAN TAŞINAN VERİLER ---

  // ODA KAPASİTESİ FİLTRESİ
  static const List<int> roomSizes = [1, 2, 3, 4];

  // FİYAT ARALIĞI FİLTRESİ
  static final List<PriceRange> priceRanges = [
    PriceRange(0, 5000),
    PriceRange(5000, 10000),
    PriceRange(10000, 15000),
    PriceRange(15000, 99999),
  ];
}
