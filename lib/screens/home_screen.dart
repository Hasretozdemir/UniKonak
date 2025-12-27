import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dormitory_model.dart';
import '../models/notification_model.dart';
import '../models/filter_models.dart';
import '../utils/constants.dart';
import '../widgets/dormitory_card.dart';
import '../widgets/filter_sheet.dart';
import 'notification_screen.dart';
import 'favorites_screen.dart';
import 'profile_tab.dart';

class UniKonakHome extends StatefulWidget {
  const UniKonakHome({super.key});

  @override
  State<UniKonakHome> createState() => _UniKonakHomeState();
}

class _UniKonakHomeState extends State<UniKonakHome> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    
  }

 
  Stream<List<Dormitory>> readDormitories() {
    return FirebaseFirestore.instance.collection('yurtlar').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Dormitory.fromSnapshot(doc)).toList());
  }

  Stream<List<AppNotification>> getNotifications() {
    return FirebaseFirestore.instance
        .collection('bildirimler')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromSnapshot(doc))
            .toList());
  }

  
  void _markAsRead(AppNotification notification) {
    if (notification.id.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('bildirimler')
          .doc(notification.id)
          .update({'isRead': true});
    }
  }

  void _toggleFavorite(Dormitory dorm) {
    FirebaseFirestore.instance
        .collection('yurtlar')
        .doc(dorm.id)
        .update({'isFavorite': !dorm.isFavorite});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Anasayfa'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: 'Favoriler'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppConstants.accentColor,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 2) return const ProfileTab();

    // 1. STREAM: Yurt verilerini dinle
    return StreamBuilder<List<Dormitory>>(
      stream: readDormitories(),
      builder: (context, dormSnapshot) {
        if (dormSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dorms = dormSnapshot.data ?? [];

        if (_selectedIndex == 1) {
          return FavoritesScreen(
              allDormitories: dorms, onToggleFavorite: _toggleFavorite);
        }

    
        return StreamBuilder<List<AppNotification>>(
          stream: getNotifications(),
          builder: (context, notifSnapshot) {
        
            final notifications = notifSnapshot.data ?? [];

            return Column(
              children: [
               
                _buildCustomHeader(dorms, notifications),
                Expanded(
                  child: HomeScreenContent(
                    allDormitories: dorms,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCustomHeader(
      List<Dormitory> dorms, List<AppNotification> notifications) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 114, 122, 128),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tekrar Merhaba, 👋",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                currentUser?.displayName?.split(' ')[0] ?? "Öğrenci",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(
                          notifications: notifications, 
                          onMarkAsRead:
                              _markAsRead,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final List<Dormitory> allDormitories;
  final Function(Dormitory) onToggleFavorite;

  const HomeScreenContent({
    super.key,
    required this.allDormitories,
    required this.onToggleFavorite,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Dormitory> _filteredDormitories = [];

  String? _selectedCity;
  String? _selectedUniversity;
  int? _selectedRoomSize;
  PriceRange? _selectedPriceRange;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _filteredDormitories = widget.allDormitories;
  }

  @override
  void didUpdateWidget(covariant HomeScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allDormitories != widget.allDormitories) {
      _applyFilters();
    }
  }

  void _applyFilters() {
    setState(() {
      String searchText = _searchController.text.toLowerCase();

      _filteredDormitories = widget.allDormitories.where((dorm) {
        bool matchesSearch = searchText.isEmpty ||
            dorm.name.toLowerCase().contains(searchText) ||
            dorm.searchKeywords.any((kw) => kw.contains(searchText));

        bool matchesCity = _selectedCity == null ||
            dorm.searchKeywords.contains(_selectedCity!.toLowerCase());

        bool matchesUni = _selectedUniversity == null ||
            dorm.universities.contains(_selectedUniversity);

        bool matchesRoom = _selectedRoomSize == null ||
            dorm.roomPrices.containsKey(_selectedRoomSize);

        bool matchesGender =
            _selectedGender == null || dorm.gender == _selectedGender;

        bool matchesPrice = true;
        if (_selectedPriceRange != null) {
          if (_selectedRoomSize != null && matchesRoom) {
            int price = dorm.roomPrices[_selectedRoomSize]!;
            matchesPrice = price >= _selectedPriceRange!.minPrice &&
                price <= _selectedPriceRange!.maxPrice;
          } else {
            matchesPrice = dorm.roomPrices.values.any((price) =>
                price >= _selectedPriceRange!.minPrice &&
                price <= _selectedPriceRange!.maxPrice);
          }
        }

        return matchesSearch &&
            matchesCity &&
            matchesUni &&
            matchesRoom &&
            matchesPrice &&
            matchesGender;
      }).toList();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSelectionSheet(
        initialCity: _selectedCity,
        initialUniversity: _selectedUniversity,
        initialRoomSize: _selectedRoomSize,
        initialPriceRange: _selectedPriceRange,
        initialGender: _selectedGender,
        onApplyFilters: (city, uni, size, price, gender) {
          setState(() {
            _selectedCity = city;
            _selectedUniversity = uni;
            _selectedRoomSize = size;
            _selectedPriceRange = price;
            _selectedGender = gender;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => _applyFilters(),
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Yurt, Şehir veya Üniversite Ara...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon:
                      const Icon(Icons.search, color: AppConstants.accentColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.grey),
                    onPressed: _openFilterSheet,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredDormitories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text("Kriterlere uygun yurt bulunamadı",
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 0, left: 16, right: 16, bottom: 20),
                  itemCount: _filteredDormitories.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOut,
                      builder: (context, double val, child) {
                        return Opacity(
                          opacity: val,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - val)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: DormitoryCard(
                                dorm: _filteredDormitories[index],
                                onToggleFavorite: widget.onToggleFavorite,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
