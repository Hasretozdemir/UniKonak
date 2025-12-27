import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/filter_models.dart';
import '../utils/constants.dart'; 

class FilterSelectionSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialUniversity;
  final int? initialRoomSize;
  final PriceRange? initialPriceRange;
  final String? initialGender;
  final Function(String?, String?, int?, PriceRange?, String?) onApplyFilters;

  const FilterSelectionSheet({
    super.key,
    required this.initialCity,
    required this.initialUniversity,
    required this.initialRoomSize,
    required this.initialPriceRange,
    this.initialGender,
    required this.onApplyFilters,
  });

  @override
  State<FilterSelectionSheet> createState() => _FilterSelectionSheetState();
}

class _FilterSelectionSheetState extends State<FilterSelectionSheet> {
  String? _selectedCity;
  String? _selectedUniversity;
  int? _selectedRoomSize;
  PriceRange? _selectedPriceRange;
  String? _selectedGender;

  // Canlı veritabanından çekilen şehirler burada tutulacak
  List<CityFilter> _fetchedCities = [];
  List<String> _universitiesInSelectedCity = [];
  bool _isLoading = true; // Veriler yükleniyor mu?

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _selectedUniversity = widget.initialUniversity;
    _selectedRoomSize = widget.initialRoomSize;
    _selectedPriceRange = widget.initialPriceRange;
    _selectedGender = widget.initialGender;

    
    _fetchCities();
  }

  
  Future<void> _fetchCities() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('sehirler').get();

      if (mounted) {
        setState(() {
       
          _fetchedCities = snapshot.docs.map((doc) {
            final data = doc.data();
            return CityFilter(
              data['name'] ?? '', 
              List<String>.from(data['universities'] ??
                  []), 
            );
          }).toList();

          _isLoading = false;

      
          if (_selectedCity != null) {
            final filter = _fetchedCities.firstWhere(
              (f) => f.city == _selectedCity,
              orElse: () => CityFilter('', []),
            );
           
            if (filter.city.isNotEmpty) {
              _universitiesInSelectedCity = filter.universities;
            } else {
              _universitiesInSelectedCity = [];
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Hata: Şehirler çekilemedi -> $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCitySelected(String? city) {
    setState(() {
      if (_selectedCity == city) {
 
        _selectedCity = null;
        _universitiesInSelectedCity = [];
      } else {
   
        _selectedCity = city;
        if (city != null) {
       
          final filter = _fetchedCities.firstWhere(
            (f) => f.city == city,
            orElse: () => CityFilter('', []),
          );
          _universitiesInSelectedCity = filter.universities;
        } else {
          _universitiesInSelectedCity = [];
        }
      }
      _selectedUniversity = null;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _selectedUniversity = null;
      _selectedRoomSize = null;
      _selectedPriceRange = null;
      _selectedGender = null;
      _universitiesInSelectedCity = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      height: MediaQuery.of(context).size.height * 0.90,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Cinsiyet', Icons.people_outline),
                  _buildGenderSelector(),
                  const SizedBox(height: 25),
                  _buildSectionTitle('Şehir', Icons.location_on_outlined),
                  _buildCitySelector(), // Güncellendi
                  const SizedBox(height: 25),
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Üniversite', Icons.school_outlined),
                        _buildUniversitySelector(),
                        const SizedBox(height: 25),
                      ],
                    ),
                    crossFadeState: _universitiesInSelectedCity.isNotEmpty
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  _buildSectionTitle('Oda Kapasitesi', Icons.bed_outlined),
                  _buildRoomSizeSelector(),
                  const SizedBox(height: 25),
                  _buildSectionTitle('Fiyat Aralığı', Icons.attach_money),
                  _buildPriceSelector(),
                ],
              ),
            ),
          ),
          _buildBottomActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Filtrele",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            child: const Text("Temizle"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.accentColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildBigSelectableCard(
            title: "Kız Öğrenci",
            icon: Icons.female,
            isSelected: _selectedGender == "Kız",
            onTap: () => setState(() =>
                _selectedGender = _selectedGender == "Kız" ? null : "Kız"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildBigSelectableCard(
            title: "Erkek Öğrenci",
            icon: Icons.male,
            isSelected: _selectedGender == "Erkek",
            onTap: () => setState(() =>
                _selectedGender = _selectedGender == "Erkek" ? null : "Erkek"),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySelector() {
    
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

  
    if (_fetchedCities.isEmpty) {
      return const Text("Kayıtlı şehir bulunamadı.");
    }

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _fetchedCities.length, 
        itemBuilder: (context, index) {
          final city = _fetchedCities[index].city; // Canlı veriden şehri al
          final isSelected = _selectedCity == city;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildCustomChip(
              label: city,
              isSelected: isSelected,
              onTap: () => _onCitySelected(city),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUniversitySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _universitiesInSelectedCity.map((uni) {
        final isSelected = _selectedUniversity == uni;
        return _buildCustomChip(
          label: uni,
          isSelected: isSelected,
          onTap: () =>
              setState(() => _selectedUniversity = isSelected ? null : uni),
        );
      }).toList(),
    );
  }

  Widget _buildRoomSizeSelector() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: AppConstants.roomSizes.map((size) {
        final isSelected = _selectedRoomSize == size;
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedRoomSize = isSelected ? null : size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppConstants.accentColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppConstants.accentColor
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppConstants.accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                Text(
                  "$size",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSelector() {
    
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.priceRanges.map((range) {
        String label =
            '${range.minPrice.toInt()} - ${range.maxPrice.toInt()} TL';
        if (range.maxPrice >= 99999) label = '+15.000 TL';
        final isSelected = _selectedPriceRange?.minPrice == range.minPrice;

        return _buildCustomChip(
          label: label,
          isSelected: isSelected,
          onTap: () =>
              setState(() => _selectedPriceRange = isSelected ? null : range),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(
                _selectedCity,
                _selectedUniversity,
                _selectedRoomSize,
                _selectedPriceRange,
                _selectedGender,
              );
              Navigator.pop(
                  context); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              shadowColor: AppConstants.accentColor.withOpacity(0.4),
            ),
            child: const Text(
              "Sonuçları Göster",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.accentColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.accentColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppConstants.accentColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBigSelectableCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.accentColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppConstants.accentColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppConstants.accentColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppConstants.accentColor : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
