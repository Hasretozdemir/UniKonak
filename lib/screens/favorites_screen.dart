// --- KÜTÜPHANE VE DOSYA İÇE AKTARMA ---
import 'package:flutter/material.dart'; // Temel Flutter görsel bileşenleri.
import '../models/dormitory_model.dart'; // Yurt veri modelini (Dormitory sınıfı) tanımak için.
import '../utils/constants.dart'; // Uygulama renkleri (AccentColor vb.) için.
import 'dormitory_detail_screen.dart'; // Karta tıklanınca gidilecek detay sayfası.

// --- STATEFUL WIDGET TANIMI ---
// Liste dinamik olacağı (favoriden çıkarma işlemi yapılacağı) için StatefulWidget kullanıyoruz.
class FavoritesScreen extends StatefulWidget {
  // Tüm yurtların listesi buraya parametre olarak gelir.
  final List<Dormitory> allDormitories;

  // Favori durumunu değiştiren fonksiyon (Ana sayfadaki durumu güncellemek için gereklidir).
  final Function(Dormitory) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.allDormitories, // Zorunlu parametre.
    required this.onToggleFavorite, // Zorunlu parametre.
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

// --- STATE (DURUM) SINIFI ---
class _FavoritesScreenState extends State<FavoritesScreen> {
  // --- EKRAN ÇİZİMİ (BUILD) ---
  @override
  Widget build(BuildContext context) {
    // 1. ADIM: FAVORİLERİ FİLTRELEME
    // Gelen tüm yurtlar listesinden, sadece 'isFavorite' değeri 'true' olanları seçip yeni bir liste yapar.
    final favoriteDorms =
        widget.allDormitories.where((dorm) => dorm.isFavorite).toList();

    // 2. ADIM: TEMA AYARLARI
    // Telefonun karanlık modda olup olmadığını kontrol eder.
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Boş durumdaki yazı renklerini temaya göre ayarlar (Karanlıksa açık renk, aydınlıksa koyu renk).
    final Color emptyTextColor = isDark ? Colors.white70 : Colors.grey[600]!;
    final Color emptyTitleColor =
        isDark ? Colors.white : const Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: Colors
          .transparent, // Arka plan şeffaf (Ana sayfanın arka planı görünsün diye).

      // Sayfa yapısı: Üst Başlık + Liste
      body: Column(
        children: [
          // --- ÜST BAŞLIK ALANI (HEADER) ---
          Container(
            // İç boşluklar (Padding)
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
            decoration: const BoxDecoration(
                color: Colors.white, // Başlık arka planı beyaz.
                // Sadece alt köşeleri yuvarlat.
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                // Hafif bir gölge ekle.
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ]),
            // Yan yana elemanlar (Başlık ve Sayaç).
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
                const Spacer(), // Araya boşluk koyarak sayacı sağa iter.

                // Yurt Sayısını Gösteren Küçük Kutu (Chip)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor
                        .withOpacity(0.1), // Açık yeşil/mavi tonu.
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${favoriteDorms.length} Yurt", // "3 Yurt" gibi yazar.
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

          // --- LİSTE ALANI ---
          Expanded(
            // Kalan tüm boşluğu kapla.
            child: favoriteDorms.isEmpty
                // EĞER LİSTE BOŞSA: Boş durum tasarımını göster.
                ? _buildEmptyState(emptyTitleColor, emptyTextColor)
                // EĞER DOLUYSA: Listeyi oluştur.
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: favoriteDorms.length, // Kaç eleman var?
                    itemBuilder: (context, index) {
                      final dorm = favoriteDorms[index];

                      // TweenAnimationBuilder: Listeye giriş animasyonu.
                      // Her eleman hafifçe aşağıdan yukarı kayarak ve şeffaflıktan görünüre geçerek gelir.
                      return TweenAnimationBuilder(
                        duration: Duration(
                            milliseconds: 400 +
                                (index *
                                    100)), // Her eleman biraz daha geç gelsin.
                        tween: Tween<double>(
                            begin: 0, end: 1), // 0'dan 1'e animasyon.
                        curve: Curves.easeOutQuad, // Yumuşak geçiş eğrisi.
                        builder: (context, double val, child) {
                          return Opacity(
                            opacity: val, // Şeffaflık ayarı.
                            child: Transform.translate(
                              offset: Offset(0,
                                  50 * (1 - val)), // Aşağıdan yukarı kaydırma.
                              child:
                                  _buildFavoriteCard(dorm), // Asıl kartı çiz.
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

  // --- YARDIMCI WIDGET: FAVORİ KARTI TASARIMI ---
  Widget _buildFavoriteCard(Dormitory dorm) {
    // En düşük fiyatı hesapla (Listede göstermek için).
    final price = dorm.roomPrices.values.isNotEmpty
        ? dorm.roomPrices.values.reduce((a, b) => a < b ? a : b)
        : 0;

    // İlk resmi al.
    final imageUrl = dorm.imageUrls.isNotEmpty ? dorm.imageUrls.first : '';
    // Resim internetten mi geliyor kontrol et.
    final isNetworkImage = imageUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Kartlar arası boşluk.
      height: 130, // Kart yüksekliği sabit.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Kart gölgesi.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Material ve InkWell: Tıklama efekti (dalga) için gerekli.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          // Karta tıklanınca Detay Sayfasına git.
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DormitoryDetailPage(
                  dorm: dorm,
                  onToggleFavorite: widget
                      .onToggleFavorite, // Favori fonksiyonunu detay sayfasına da taşı.
                ),
              ),
            );
          },
          // Kart İçeriği (Resim + Bilgiler)
          child: Row(
            children: [
              // --- SOL TARAF: RESİM ---
              Hero(
                // Hero: Sayfa geçişinde resmin uçarak gitmesi efekti.
                tag: "fav_${dorm.id}", // Benzersiz ID.
                child: Container(
                  width: 120,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    // Resmi arka plan olarak ayarla.
                    image: DecorationImage(
                      image: (imageUrl.isNotEmpty
                              ? (isNetworkImage
                                  ? NetworkImage(imageUrl) // İnternet resmi.
                                  : AssetImage(imageUrl)) // Yerel resim.
                              : const AssetImage(
                                  'assets/images/placeholder.png')) // Resim yoksa yer tutucu.
                          as ImageProvider,
                      fit: BoxFit.cover, // Resmi kutuya sığdır (kırparak).
                    ),
                  ),
                  // Resim URL'i tamamen boşsa ikon göster.
                  child: imageUrl.isEmpty
                      ? const Center(
                          child: Icon(Icons.apartment, color: Colors.grey))
                      : null,
                ),
              ),

              // --- SAĞ TARAF: BİLGİLER ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Dikeyde yay.
                    children: [
                      // Üst Satır: İsim ve Puan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dorm.name,
                              maxLines: 2, // En fazla 2 satır.
                              overflow:
                                  TextOverflow.ellipsis, // Sığmazsa ... koy.
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ),
                          // Puan Kutusu (Sarı)
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

                      // Orta Satır: Konum
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

                      // Alt Satır: Fiyat ve Silme Butonu
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
                          // Favoriden Çıkarma Butonu (Kırmızı Kalp)
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
                                // Favori durumunu değiştir.
                                widget.onToggleFavorite(dorm);
                                // Kullanıcıya altta bilgi mesajı göster.
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

  // --- YARDIMCI WIDGET: BOŞ DURUM TASARIMI ---
  // Favori hiç yurt yoksa ekranda görünecek olan tasarım.
  Widget _buildEmptyState(Color titleColor, Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Büyük yuvarlak içinde kalp ikonu.
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
          // Başlık
          Text(
            'Listeniz Henüz Boş',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          // Alt açıklama metni
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
