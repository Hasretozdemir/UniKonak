import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hakkımızda",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryBackgroundColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apartment_rounded,
                  size: 80, color: AppConstants.primaryBackgroundColor),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Text(
                      "Hoş Geldiniz!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBackgroundColor,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Merhabalar, Ben Hasret Özdemir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Gazi Üniversitesi TUSAŞ Kazan Meslek Yüksekokulu Bilgisayar Programcılığı 2. Sınıf öğrencisiyim.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, height: 1.5, color: Colors.black87),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Bu uygulama, üniversite öğrencilerinin barınma sorunlarına modern çözümler üretmek ve eğitim hayatım boyunca edindiğim teknik bilgileri somut bir projeye dönüştürmek amacıyla, ders projesi kapsamında sevgiyle geliştirilmiştir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, color: Colors.black54, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Versiyon 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gizlilik Politikası",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "1. Veri Toplama"),
            _buildSectionText(
                "ÜniKonak uygulaması, kullanıcı deneyimini iyileştirmek amacıyla ad, soyad ve e-posta adresi gibi temel bilgileri toplar. Bu veriler güvenli sunucularda saklanır.",
                textColor),
            _buildSectionTitle(context, "2. Kullanım Amacı"),
            _buildSectionText(
                "Toplanan veriler, size uygun yurtları listelemek, favorilerinizi kaydetmek ve sizinle iletişim kurmak amacıyla kullanılır.",
                textColor),
            _buildSectionTitle(context, "3. Üçüncü Taraflar"),
            _buildSectionText(
                "Kullanıcı verileriniz, yasal zorunluluklar dışında üçüncü taraflarla paylaşılmaz. Google Firebase altyapısı kullanılarak verileriniz şifrelenir.",
                textColor),
            _buildSectionTitle(context, "4. Güvenlik"),
            _buildSectionText(
                "Hesabınızın güvenliği bizim için önemlidir. Şifreniz veritabanımızda şifrelenmiş (hash) olarak saklanmaktadır.",
                textColor),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Bu metin bir taslaktır ve hukuki bağlayıcılığı yoktur.",
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.5, color: color),
    );
  }
}
