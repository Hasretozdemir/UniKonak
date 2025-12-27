// --- KÜTÜPHANE VE DOSYA İÇE AKTARMA (IMPORT) İŞLEMLERİ ---

// Flutter'ın temel görsel bileşenlerini (Widget'lar, Renkler, Temalar) içeren ana paket.
import 'package:flutter/material.dart';

// Harita gösterimi için Google Maps paketini dahil ediyoruz.
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Yurt verilerini tutan model dosyamızı dahil ediyoruz (Veri yapısını bilmek için).
import '../models/dormitory_model.dart';

// Uygulama genelinde kullanılan sabit renkleri ve değerleri içeren dosyayı alıyoruz.
import '../utils/constants.dart';

// Yorumların listelendiği ve yeni yorum yazılan alt bileşeni (Widget) alıyoruz.
import '../widgets/comment_section.dart';

// Randevu alma formunu içeren alt pencere bileşenini alıyoruz.
import '../widgets/appointment_sheet.dart';

// --- STATEFUL WIDGET TANIMI ---
// Bu sayfa ekrandaki değişimleri (fiyat değişimi, resim değişimi vb.) yöneteceği için
// StatefulWidget kullanıyoruz. Sadece statik bir görüntü olsaydı StatelessWidget yeterli olurdu.
class DormitoryDetailPage extends StatefulWidget {
  // Bu sayfaya dışarıdan (örneğin ana sayfadan) gönderilen veriler:

  final Dormitory dorm; // Tıklanan yurdun tüm bilgilerini içeren nesne.

  // Favori butonuna basıldığında ana sayfadaki listeyi de güncelleyecek olan fonksiyon.
  // Bu fonksiyon, bir Dormitory nesnesi alır ve geriye bir şey döndürmez (void).
  final Function(Dormitory) onToggleFavorite;

  // Yapıcı Metot (Constructor)
  // 'required' kelimesi bu verilerin mutlaka gönderilmesi gerektiğini belirtir.
  const DormitoryDetailPage({
    super.key,
    required this.dorm,
    required this.onToggleFavorite,
  });

  // State (Durum) nesnesini oluşturur. Bu nesne sayfanın hafızasıdır.
  @override
  State<DormitoryDetailPage> createState() => _DormitoryDetailPageState();
}

// --- STATE SINIFI (SAYFANIN HAFIZASI VE MANTIĞI) ---
class _DormitoryDetailPageState extends State<DormitoryDetailPage> {
  // DEĞİŞKEN TANIMLARI

  // Seçilen oda kapasitesi (Örn: 1, 3, 4). 'late' anahtar kelimesi, bu değişkenin
  // hemen değil, sayfa yüklenirken (initState içinde) değer alacağını belirtir.
  late int _selectedRoomSize;

  // Ekranda gösterilecek güncel aylık fiyat.
  late int _currentPrice;

  // Ekranda gösterilecek güncel depozito fiyatı.
  late int _currentDepositPrice;

  // Fotoğraf galerisinde şu an hangi resmin seçili olduğunu tutan indeks (Sıra numarası).
  // 0, ilk resim demektir.
  int _selectedImageIndex = 0;

  // --- BAŞLANGIÇ AYARLARI (INITSTATE) ---
  // Sayfa ekrana ilk kez çizilmeden hemen önce çalışan metottur.
  @override
  void initState() {
    super.initState(); // Üst sınıfın (State) başlangıç ayarlarını çalıştırır.

    // 1. Adım: Yurdun oda fiyatlarını (keys) alıp bir listeye çeviriyoruz.
    // ..sort() diyerek bu listeyi küçükten büyüğe sıralıyoruz (1, 2, 3, 4 gibi).
    final sortedSizes = widget.dorm.roomPrices.keys.toList()..sort();

    // 2. Adım: Eğer liste boş değilse ilk elemanı (en az kişilik oda), boşsa 0'ı seçiyoruz.
    // 'widget.dorm' diyerek üst sınıftaki (DormitoryDetailPage) verilere erişiyoruz.
    _selectedRoomSize = sortedSizes.isNotEmpty ? sortedSizes.first : 0;

    // 3. Adım: Seçilen odaya göre fiyatları hesaplayan fonksiyonu çağırıyoruz.
    _updatePrices(_selectedRoomSize);
  }

  // --- FİYAT GÜNCELLEME FONKSİYONU ---
  // Kullanıcı "3 Kişilik" kutucuğuna tıkladığında bu fonksiyon çalışır.
  void _updatePrices(int size) {
    if (size == 0) return; // Geçersiz bir boyut gelirse işlem yapma.

    // setState: Flutter'a "Veriler değişti, ekranı yeniden çiz" komutunu verir.
    // Bu olmazsa değişkenler değişir ama ekrandaki sayılar aynı kalır.
    setState(() {
      _selectedRoomSize = size; // Seçilen odayı güncelle.
      _currentPrice = widget.dorm.roomPrices[
          size]!; // Yeni fiyatı sözlükten (Map) al. (!) işareti "kesinlikle var" demektir.
      _currentDepositPrice =
          widget.dorm.depositPrices[size] ?? 0; // Depozitoyu al, yoksa 0 yaz.
    });
  }

  // --- RANDEVU PENCERESİ GÖSTERME ---
  // "Randevu Al" butonuna basınca çalışır.
  void _showAppointmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context, // Hangi ekranda açılacağını belirtir.
      isScrollControlled:
          true, // Pencerenin tam ekran yüksekliğine çıkmasına izin verir.
      backgroundColor: Colors
          .transparent, // Arka planı şeffaf yapar (köşeleri yuvarlatmak için).
      builder: (_) =>
          const AppointmentSheet(), // İçerik olarak AppointmentSheet bileşenini gösterir.
    );
  }

  // --- EKRAN ÇİZİMİ (BUILD) ---
  // Flutter'da her şey bu metot içinde çizilir.
  @override
  Widget build(BuildContext context) {
    // Galeride gösterilecek aktif resmin URL'ini belirle.
    final activeImageUrl = widget.dorm.imageUrls.isNotEmpty
        ? widget
            .dorm.imageUrls[_selectedImageIndex] // Seçili indeksteki resmi al.
        : ''; // Resim yoksa boş metin.

    // Resmin internetten mi (http) yoksa telefondan mı (asset) geldiğini kontrol et.
    final bool isNetworkImage = activeImageUrl.startsWith('http');

    // Sayfa iskeletini (Scaffold) oluştur.
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA), // Arka plan rengi (Açık gri tonu).

      // CustomScrollView: Sayfada birden fazla kaydırılabilir alanı birleştirmek için kullanılır.
      // Özellikle yukarıdaki resmin kaydırınca küçülmesi (SliverAppBar) efekti için gereklidir.
      body: CustomScrollView(
        slivers: [
          // --- 1. ESNEK ÜST BAR (SLIVER APP BAR) ---
          SliverAppBar(
            expandedHeight:
                300.0, // Açık haldeki yükseklik (Büyük resim boyutu).
            pinned:
                true, // Yukarı kaydırınca barın en üstte sabit kalmasını sağlar.
            backgroundColor:
                AppConstants.accentColor, // Sabitlendiğindeki arka plan rengi.
            iconTheme: const IconThemeData(
                color: Colors.white), // Geri butonu rengi beyaz.

            // Sağ üstteki aksiyon butonları (Favori Kalbi).
            actions: [
              Container(
                margin:
                    const EdgeInsets.only(right: 16), // Sağdan boşluk bırak.
                decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape
                        .circle), // Yarı saydam siyah yuvarlak arka plan.
                child: IconButton(
                  // Yurt favori mi? Evetse dolu kalp, hayırsa boş kalp ikonu göster.
                  icon: Icon(
                    widget.dorm.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    // Yurt favori mi? Evetse kırmızı, hayırsa beyaz renk.
                    color: widget.dorm.isFavorite
                        ? Colors.redAccent
                        : Colors.white,
                  ),
                  // Tıklanınca favori durumunu değiştiren fonksiyonu çalıştır.
                  onPressed: () => widget.onToggleFavorite(widget.dorm),
                ),
              ),
            ],

            // Esnek alanın içindeki içerik (Arka plan resmi).
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                // Üst üste eleman koymak için Stack kullanılır.
                fit: StackFit.expand, // Alanı tamamen kapla.
                children: [
                  // Resim Gösterimi
                  widget.dorm.imageUrls.isNotEmpty
                      ? (isNetworkImage
                          ? Image.network(activeImageUrl,
                              fit: BoxFit.cover) // İnternetten yükle.
                          : Image.asset(activeImageUrl,
                              fit: BoxFit.cover)) // Dosyalardan yükle.
                      : Container(
                          color: Colors.grey,
                          child: const Icon(Icons
                              .image_not_supported), // Resim yoksa ikon göster.
                        ),

                  // Gölge Efekti (Gradient)
                  // Resmin üzerine yukarıdan aşağıya koyulaşan bir tabaka ekler.
                  // Bu sayede beyaz yazılar resmin üzerinde okunabilir olur.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54
                        ], // Şeffaftan siyaha geçiş.
                        stops: [
                          0.6,
                          1.0
                        ], // Geçişin başladığı ve bittiği noktalar.
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. SAYFA İÇERİĞİ (LİSTE OLMAYAN ELEMAN) ---
          SliverToBoxAdapter(
            child: Container(
              // transform: Konteyneri Y ekseninde -20 piksel yukarı kaydırır.
              // Bu, beyaz alanın resmin üzerine hafifçe binmesini ve kavisli görünmesini sağlar.
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA), // Arka plan rengi.
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30)), // Üst köşeleri yuvarlat.
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    20.0), // İçerikten 20 birim boşluk bırak.
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Her şeyi sola hizala.
                  children: [
                    // Gri Çizgi (Sürükleme işareti gibi görünen dekoratif çubuk).
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

                    // "Fotoğraflar" Başlığı
                    const Text("Fotoğraflar",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                    const SizedBox(height: 10), // Boşluk.

                    // Küçük resimlerin olduğu yatay liste (Yardımcı metot çağrılıyor).
                    _buildPhotoGallery(widget.dorm.imageUrls),

                    const SizedBox(height: 25), // Boşluk.

                    // YURT ADI VE PUANI
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Sağa ve sola yasla.
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Yurt Adı (Expanded: Metin uzunsa alt satıra geçsin diye).
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

                        // Puan Kutusu (Sarı)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.amber, // Sarı renk.
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 18,
                                  color: Colors.white), // Yıldız ikonu.
                              const SizedBox(width: 4),
                              Text(widget.dorm.rating, // Puan değeri.
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // KONUM METNİ
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                          child: Text("İstanbul, Üsküdar",
                              style: TextStyle(color: Colors.grey[600]))),
                    ]),

                    const SizedBox(height: 25),
                    const Divider(), // İnce gri bir ayırıcı çizgi.
                    const SizedBox(height: 15),

                    // ODA SEÇİMİ BAŞLIĞI
                    const Text("Oda Seçimi",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // YATAY KAYDIRILABİLİR ODA LİSTESİ
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        // Yurdun oda tiplerini (keys) alıp her biri için bir kart oluşturuyoruz.
                        children: widget.dorm.roomPrices.keys.map((size) {
                          // Bu kartın seçili olup olmadığını kontrol et.
                          bool isSelected = _selectedRoomSize == size;

                          // Tıklanabilir alan oluştur.
                          return GestureDetector(
                            onTap: () => _updatePrices(
                                size), // Tıklanınca fiyatı güncelle.
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                  // Seçiliyse ana renk (mavi/yeşil), değilse beyaz.
                                  color: isSelected
                                      ? AppConstants.accentColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: isSelected
                                          ? AppConstants.accentColor
                                          : Colors.grey.shade300),
                                  // Seçiliyse gölge ekle.
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                          color: AppConstants.accentColor
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                  ]),
                              child: Column(
                                children: [
                                  Icon(Icons.bed, // Yatak ikonu.
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
                        }).toList(), // Map işlemini listeye çevir.
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BİLGİ KARTLARI (Depozito ve Ulaşım)
                    // _buildFeatureCard metodunu kullanarak kod tekrarını önlüyoruz.
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

                    // HARİTA BÖLÜMÜ
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
                      // ClipRRect: Haritanın köşelerini yuvarlatmak için haritayı keser.
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GoogleMap(
                          // Harita ilk açıldığında kameranın nereye bakacağı.
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                widget.dorm.latitude, widget.dorm.longitude),
                            zoom: 14.0, // Yakınlaştırma seviyesi.
                          ),
                          // Harita üzerindeki kırmızı işaretçi (pin).
                          markers: {
                            Marker(
                                markerId: MarkerId(widget.dorm.name),
                                position: LatLng(widget.dorm.latitude,
                                    widget.dorm.longitude))
                          },
                          zoomGesturesEnabled:
                              true, // Elle yakınlaştırmaya izin ver.
                          scrollGesturesEnabled:
                              false, // Sayfa kaydığı için harita kaydırmayı kapat.
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Divider(),

                    // YORUMLAR BÖLÜMÜ (Başka bir dosyadan çağrılan Widget).
                    CommentSection(dormitoryId: widget.dorm.id),
                    const SizedBox(
                        height:
                            100), // En altta butonların üstüne binmemesi için boşluk.
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // --- ALT BAR (FİYAT VE BUTONLAR) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5), // Gölgeyi yukarı doğru ver.
            ),
          ],
        ),
        // SafeArea: Çentikli telefonlarda (iPhone X vb.) içeriğin kesilmesini önler.
        child: SafeArea(
          child: Row(
            children: [
              // Sol Taraf: Fiyat Bilgisi
              Expanded(
                flex: 2, // Sol taraf 2 birim yer kaplasın.
                child: Column(
                  mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kapla.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Aylık Fiyat",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      "$_currentPrice TL", // Seçilen odanın fiyatı.
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Sağ Taraf: Butonlar
              Expanded(
                flex: 3, // Sağ taraf 3 birim yer kaplasın (Daha geniş).
                child: Row(
                  children: [
                    // Arama Butonu (Yeşil kutu içinde telefon ikonu).
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
                          // Ekrana geçici bir bilgi mesajı (SnackBar) göster.
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("${widget.dorm.phoneNumber} aranıyor..."),
                            backgroundColor: Colors.green,
                          ));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Randevu Al Butonu (Uzun buton).
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

  // --- YARDIMCI METOT: FOTOĞRAF GALERİSİ OLUŞTURUCU ---
  // Kod tekrarını önlemek için küçük resim listesi burada oluşturulur.
  Widget _buildPhotoGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty)
      return const SizedBox(); // Resim yoksa hiçbir şey çizme.

    return SizedBox(
      height: 90, // Galerinin yüksekliği.
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Yatay kaydırma.
        itemCount: imageUrls.length, // Kaç tane resim varsa o kadar oluştur.
        itemBuilder: (context, index) {
          final url = imageUrls[index]; // Sıradaki resmin yolu.
          bool isNetworkImage = url.startsWith('http'); // İnternetten mi?
          bool isSelected =
              _selectedImageIndex == index; // Bu resim şu an seçili mi?

          return GestureDetector(
            onTap: () {
              // Resme tıklanınca seçili resmi değiştir (Büyük resim de değişir).
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Seçiliyse etrafına kalın renkli çerçeve çiz.
                border: isSelected
                    ? Border.all(color: AppConstants.accentColor, width: 3)
                    : Border.all(color: Colors.transparent, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                // Resmi yükle (Hata olursa gri kutu göster).
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

  // --- YARDIMCI METOT: ÖZELLİK KARTI OLUŞTURUCU ---
  // Depozito ve Ulaşım kartları birbirine çok benzediği için tek bir kalıp kullanıyoruz.
  Widget _buildFeatureCard(
      {required IconData icon, // Karttaki ikon
      required String title, // Başlık (Örn: Depozito)
      required String value, // Değer (Örn: 5000 TL)
      String? subValue, // Alt açıklama (Opsiyonel)
      required Color color}) {
    // İkon rengi

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(
        children: [
          // Sol taraftaki renkli ikon kutusu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Rengin şeffaf hali.
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          // Yazılar
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
                // Eğer alt açıklama varsa göster.
                if (subValue != null)
                  Text(subValue,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
