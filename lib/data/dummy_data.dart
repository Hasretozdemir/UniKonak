import '../models/dormitory_model.dart';
import '../models/notification_model.dart';
import '../models/filter_models.dart';

final List<Dormitory> allDormitories = [
  Dormitory(
    name: "Çamlıca Kız Yurdu",
    description:
        "Modern odalar, geniş sosyal alanlar, 7/24 güvenlik ve merkezi konum. Her şey dahil fiyatlar.",
    rating: "4.5/5",
    transport: "18 Dk. Metroyla (Üniversiteye)",
    phoneNumber: "+90 216 555 44 33",
    schoolDistanceDetail:
        "Yurdumuz, İstanbul Teknik Üniversitesi'ne (İTÜ) metro ile tek vasıtayla 18 dakikada ulaşım imkanı sunar.",
    depositPrices: const {
      1: 10000,
      2: 7000,
      3: 5000,
      4: 4000,
    },
    imageUrls: const [
      'assets/images/yurt1.jpeg',
      'assets/images/yurt2.jpeg',
      'assets/images/yurt3.jpeg',
      'assets/images/yurt4.jpeg',
      'assets/images/yurt.jpeg',
    ],
    roomPrices: const {1: 15000, 2: 10000, 3: 7500, 4: 6000},
    isFavorite: true,
    latitude: 41.0267,
    longitude: 29.0682,
    universities: const ['İTÜ', 'Üsküdar Üniversitesi', 'Medipol Üniversitesi'],
    searchKeywords: const [
      'istanbul',
      'üsküdar',
      'çamlıca',
      'kız yurdu',
      'itü',
      'yüksekokul'
    ],
    gender: 'Kız',
  ),
  Dormitory(
    name: "Cadde Apartları",
    description:
        "Öğrenci dostu modern apart daireler. Faturalar fiyata dahildir.",
    rating: "4.2/5",
    transport: "Yürüme Mesafesinde (5 Dk.)",
    phoneNumber: "+90 530 111 22 33",
    schoolDistanceDetail:
        "Marmara Üniversitesi Göztepe Kampüsüne sadece 5 dakikalık yürüme mesafesindedir.",
    depositPrices: const {1: 5000, 2: 3500},
    imageUrls: const [],
    roomPrices: const {1: 12000, 2: 8000},
    isFavorite: false,
    latitude: 40.9819,
    longitude: 29.0576,
    universities: const ['Marmara Üniversitesi', 'Doğuş Üniversitesi'],
    searchKeywords: const [
      'istanbul',
      'kadıköy',
      'göztepe',
      'cadde',
      'apart',
      'marmara'
    ],
    gender: 'Erkek',
  ),
];

final List<AppNotification> sampleNotifications = [
  AppNotification(
    title: "Yurt Onayı Bekleniyor",
    body:
        "Çamlıca Kız Yurdu için yaptığınız başvurunun onayı bekleniyor. Lütfen belgelerinizi yükleyin.",
    date: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AppNotification(
    title: "Yeni Kampanya",
    body:
        "Erken kayıt yaptıran ilk 50 kişiye depozito indirimi fırsatını kaçırmayın!",
    date: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
];

final List<CityFilter> availableFilters = [
  CityFilter('İstanbul', ['İTÜ', 'Boğaziçi Üniv.', 'Marmara Üniv.', 'YTÜ']),
  CityFilter('Ankara', [
    'ODTÜ',
    'Hacettepe Üniversitesi ',
    'Ankara Üniveritesi.',
    'GAZİ Üniversitesi',
  ]),
  CityFilter('İzmir', ['Ege Üniv.', 'Dokuz Eylül Üniv.']),
  CityFilter('Kütahya', ['Dumlupınar Üniversitesi']),
  CityFilter('Eskişehir', [
    'Anadolu Üniversitesi',
    'Eskişehir Teknik Üniveritesi.',
    'Osmangazi Üniversitesi',
  ]),
];

final List<int> roomSizes = [1, 2, 3, 4];

final List<PriceRange> priceRanges = [
  PriceRange(0, 5000),
  PriceRange(5000, 10000),
  PriceRange(10000, 15000),
  PriceRange(15000, 99999),
];
