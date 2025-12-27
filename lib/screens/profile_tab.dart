import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../utils/app_theme.dart';
import 'settings_pages.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
    _emailController.text = user?.email ?? "";
    _photoUrlController.text = user?.photoURL ?? "";
  }

  Widget _buildProfileHeader(Color textColor) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: textColor.withOpacity(0.5), width: 3),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                          ? NetworkImage(user!.photoURL!)
                          : null,
                  backgroundColor: Colors.grey.shade300,
                  child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                      ? Icon(Icons.person,
                          size: 60, color: Colors.grey.shade600)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: textColor,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _showEditProfileDialog,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Text(
            user?.displayName ?? "İsimsiz Kullanıcı",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            user?.email ?? "",
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Profili Düzenle",
              style: TextStyle(color: Color.fromARGB(255, 16, 33, 89))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _photoUrlController,
                  decoration: const InputDecoration(
                    labelText: "Profil Resmi Bağlantısı (URL)",
                    hintText: "https://ornek.com/resim.jpg",
                    prefixIcon: Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Ad Soyad",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Yeni Şifre (İsteğe bağlı)",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 24, 42, 71)),
              onPressed: () async {
                try {
                  if (_nameController.text != user?.displayName) {
                    await user?.updateDisplayName(_nameController.text);
                  }
                  if (_photoUrlController.text != user?.photoURL) {
                    await user?.updatePhotoURL(_photoUrlController.text);
                  }
                  if (_emailController.text != user?.email &&
                      _emailController.text.isNotEmpty) {
                    await user?.verifyBeforeUpdateEmail(_emailController.text);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Yeni e-postanıza doğrulama kodu gönderildi.")));
                  }
                  if (_passwordController.text.isNotEmpty &&
                      _passwordController.text.length >= 6) {
                    await user?.updatePassword(_passwordController.text);
                  }
                  await user?.reload();
                  setState(() {});
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Profil başarıyla güncellendi!")));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Hata: $e")));
                }
              },
              child:
                  const Text("Kaydet", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Görünüm Seç",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                title: const Text("Aydınlık Tema"),
                onTap: () {
                  themeNotifier.setTheme(AppThemeType.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.nightlight_round, color: Colors.blueGrey),
                title: const Text("Karanlık Tema"),
                onTap: () {
                  themeNotifier.setTheme(AppThemeType.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.apartment, color: Colors.blueAccent),
                title: const Text("ÜniKonak Özel Tema"),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 99, 21, 21),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text("Yeni",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                onTap: () {
                  themeNotifier.setTheme(AppThemeType.custom);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor =
        isDark ? Colors.white : const Color.fromARGB(255, 3, 52, 65);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildProfileHeader(textColor),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildSectionHeader("Kişisel Bilgiler"),
                  _buildSettingsCard(
                    icon: Icons.person_outline,
                    title: "Profili Düzenle",
                    subtitle: "İsim, E-posta, Şifre ve Resim",
                    color: const Color.fromARGB(255, 81, 145, 192),
                    onTap: _showEditProfileDialog,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Görünüm ve Uygulama"),
                  _buildSettingsCard(
                    icon: Icons.palette_outlined,
                    title: "Tema Seçimi",
                    subtitle: "Aydınlık, Karanlık veya Özel",
                    color: Colors.purple,
                    onTap: _showThemeSelector,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Hakkımızda"),
                  _buildSettingsCard(
                    icon: Icons.info_outline,
                    title: "Hakkımızda",
                    subtitle: "Geliştirici ve Proje Bilgileri",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUsScreen()));
                    },
                  ),
                  _buildSettingsCard(
                    icon: Icons.privacy_tip_outlined,
                    title: "Gizlilik Politikası",
                    subtitle: "Kullanım Şartları ve Güvenlik",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacyPolicyScreen()));
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Güvenli Çıkış",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 12, color: isDark ? Colors.grey : Colors.black54)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
