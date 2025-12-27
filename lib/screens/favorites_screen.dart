import 'package:flutter/material.dart';
import '../models/dormitory_model.dart';
import '../utils/constants.dart';
import 'dormitory_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Dormitory> allDormitories;
  final Function(Dormitory) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.allDormitories,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteDorms =
        widget.allDormitories.where((dorm) => dorm.isFavorite).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // .shade600 yerine [600] kullanmalısın
    final Color emptyTextColor = isDark ? Colors.white70 : Colors.grey[600]!;
    final Color emptyTitleColor =
        isDark ? Colors.white : const Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ]),
            child: Row(
              children: [
                const Text(
                  '❤️ Favori Yurtlarım',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${favoriteDorms.length} Yurt",
                    style: const TextStyle(
                      color: AppConstants.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: favoriteDorms.isEmpty
                ? _buildEmptyState(emptyTitleColor, emptyTextColor)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: favoriteDorms.length,
                    itemBuilder: (context, index) {
                      final dorm = favoriteDorms[index];
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOutQuad,
                        builder: (context, double val, child) {
                          return Opacity(
                            opacity: val,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - val)),
                              child: _buildFavoriteCard(dorm),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(Dormitory dorm) {
    final price = dorm.roomPrices.values.isNotEmpty
        ? dorm.roomPrices.values.reduce((a, b) => a < b ? a : b)
        : 0;

    final imageUrl = dorm.imageUrls.isNotEmpty ? dorm.imageUrls.first : '';
    final isNetworkImage = imageUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DormitoryDetailPage(
                  dorm: dorm,
                  onToggleFavorite: widget.onToggleFavorite,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Hero(
                tag: "fav_${dorm.id}",
                child: Container(
                  width: 120,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: (imageUrl.isNotEmpty
                              ? (isNetworkImage
                                  ? NetworkImage(imageUrl)
                                  : AssetImage(imageUrl))
                              : const AssetImage(
                                  'assets/images/placeholder.png'))
                          as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: imageUrl.isEmpty
                      ? const Center(
                          child: Icon(Icons.apartment, color: Colors.grey))
                      : null,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dorm.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  dorm.rating,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "İstanbul, Üsküdar",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Başlangıç",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                "$price TL",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.accentColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: Colors.red, size: 18),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                widget.onToggleFavorite(dorm);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "${dorm.name} favorilerden çıkarıldı"),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color titleColor, Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: AppConstants.accentColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Listeniz Henüz Boş',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Beğendiğiniz yurtları kalp ikonuna tıklayarak buraya ekleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: subTextColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
