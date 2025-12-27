import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/dormitory_model.dart';
import '../utils/constants.dart';
import '../widgets/comment_section.dart';
import '../widgets/appointment_sheet.dart';

class DormitoryDetailPage extends StatefulWidget {
  final Dormitory dorm;
  final Function(Dormitory) onToggleFavorite;

  const DormitoryDetailPage({
    super.key,
    required this.dorm,
    required this.onToggleFavorite,
  });

  @override
  State<DormitoryDetailPage> createState() => _DormitoryDetailPageState();
}

class _DormitoryDetailPageState extends State<DormitoryDetailPage> {
  late int _selectedRoomSize;
  late int _currentPrice;
  late int _currentDepositPrice;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    final sortedSizes = widget.dorm.roomPrices.keys.toList()..sort();
    _selectedRoomSize = sortedSizes.isNotEmpty ? sortedSizes.first : 0;
    _updatePrices(_selectedRoomSize);
  }

  void _updatePrices(int size) {
    if (size == 0) return;

    setState(() {
      _selectedRoomSize = size;
      _currentPrice = widget.dorm.roomPrices[size]!;
      _currentDepositPrice = widget.dorm.depositPrices[size] ?? 0;
    });
  }

  void _showAppointmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppointmentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeImageUrl = widget.dorm.imageUrls.isNotEmpty
        ? widget.dorm.imageUrls[_selectedImageIndex]
        : '';

    final bool isNetworkImage = activeImageUrl.startsWith('http');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppConstants.accentColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: const BoxDecoration(
                    color: Colors.black26, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(
                    widget.dorm.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.dorm.isFavorite
                        ? Colors.redAccent
                        : Colors.white,
                  ),
                  onPressed: () => widget.onToggleFavorite(widget.dorm),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.dorm.imageUrls.isNotEmpty
                      ? (isNetworkImage
                          ? Image.network(activeImageUrl, fit: BoxFit.cover)
                          : Image.asset(activeImageUrl, fit: BoxFit.cover))
                      : Container(
                          color: Colors.grey,
                          child: const Icon(Icons.image_not_supported),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const Text("Fotoğraflar",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                    const SizedBox(height: 10),
                    _buildPhotoGallery(widget.dorm.imageUrls),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.dorm.name,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(widget.dorm.rating,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                          child: Text("İstanbul, Üsküdar",
                              style: TextStyle(color: Colors.grey[600]))),
                    ]),
                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 15),
                    const Text("Oda Seçimi",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.dorm.roomPrices.keys.map((size) {
                          bool isSelected = _selectedRoomSize == size;
                          return GestureDetector(
                            onTap: () => _updatePrices(size),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppConstants.accentColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: isSelected
                                        ? AppConstants.accentColor
                                        : Colors.grey.shade300),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                        color: AppConstants.accentColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4))
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.bed,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey),
                                  const SizedBox(height: 5),
                                  Text("$size Kişilik",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildFeatureCard(
                        icon: Icons.account_balance_wallet,
                        title: "Depozito",
                        value: "$_currentDepositPrice TL",
                        color: Colors.purple),
                    _buildFeatureCard(
                        icon: Icons.directions_bus,
                        title: "Ulaşım",
                        value: widget.dorm.transport,
                        subValue: widget.dorm.schoolDistanceDetail,
                        color: Colors.orange),
                    const SizedBox(height: 25),
                    const Text("Konum",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                widget.dorm.latitude, widget.dorm.longitude),
                            zoom: 14.0,
                          ),
                          markers: {
                            Marker(
                                markerId: MarkerId(widget.dorm.name),
                                position: LatLng(widget.dorm.latitude,
                                    widget.dorm.longitude))
                          },
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    CommentSection(dormitoryId: widget.dorm.id),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Aylık Fiyat",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      "$_currentPrice TL",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("${widget.dorm.phoneNumber} aranıyor..."),
                            backgroundColor: Colors.green,
                          ));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAppointmentDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text("Randevu Al",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final url = imageUrls[index];
          bool isNetworkImage = url.startsWith('http');
          bool isSelected = _selectedImageIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppConstants.accentColor, width: 3)
                    : Border.all(color: Colors.transparent, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: isNetworkImage
                    ? Image.network(
                        url,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(width: 90, color: Colors.grey[200]),
                      )
                    : Image.asset(
                        url,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                            width: 90,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey)),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon,
      required String title,
      required String value,
      String? subValue,
      required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                if (subValue != null)
                  Text(subValue,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
