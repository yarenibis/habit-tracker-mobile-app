// lib/core/constants/badge_definitions.dart
//
// Badge sistemi:
// Badge = kullanıcının kilidini açtığı pixel art asset/sahne seviyesi
// Her yeni SceneLevel bir badge sayılır.
// Ek achievement badge'leri de eklenebilir.

class BadgeDefinition {
  final String id;
  final String emoji;          // Pixel art emoji temsili
  final String title;
  final String description;
  final String assetPath;      // Küçük ikon için (opsiyonel)
  final int requiredStreak;    // Kaç günlük streak ile açılır
  final BadgeRarity rarity;

  const BadgeDefinition({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    this.assetPath = '',
    required this.requiredStreak,
    this.rarity = BadgeRarity.common,
  });
}

enum BadgeRarity {
  common,   // Gri
  rare,     // Mavi
  epic,     // Mor
  legendary // Altın
}

extension BadgeRarityExt on BadgeRarity {
  String get label {
    switch (this) {
      case BadgeRarity.common: return 'NORMAL';
      case BadgeRarity.rare: return 'NADİR';
      case BadgeRarity.epic: return 'EPİK';
      case BadgeRarity.legendary: return 'EFSANE';
    }
  }

  // Renk (hex)
  int get colorValue {
    switch (this) {
      case BadgeRarity.common: return 0xFF9E9E9E;
      case BadgeRarity.rare: return 0xFF42A5F5;
      case BadgeRarity.epic: return 0xFFAB47BC;
      case BadgeRarity.legendary: return 0xFFFFB300;
    }
  }
}

class BadgeDefinitions {
  static const List<BadgeDefinition> all = [
    // ── Streak badge'leri ──────────────────────────────────────
    BadgeDefinition(
      id: 'first_day',
      emoji: '🌱',
      title: 'İlk Adım',
      description: 'İlk günün tamamlandı!',
      requiredStreak: 1,
      rarity: BadgeRarity.common,
    ),
    BadgeDefinition(
      id: 'three_days',
      emoji: '💧',
      title: 'Çeşme Uyandı',
      description: '3 gün üst üste tamamlandı',
      requiredStreak: 3,
      rarity: BadgeRarity.common,
    ),
    BadgeDefinition(
      id: 'one_week',
      emoji: '🌸',
      title: 'Çiçek Açtı',
      description: '7 gün kesintisiz!',
      requiredStreak: 7,
      rarity: BadgeRarity.rare,
    ),
    BadgeDefinition(
      id: 'two_weeks',
      emoji: '✨',
      title: 'Büyülü Çeşme',
      description: '14 gün tam performans',
      requiredStreak: 14,
      rarity: BadgeRarity.rare,
    ),
    BadgeDefinition(
      id: 'three_weeks',
      emoji: '🏆',
      title: 'Alışkanlık Ustası',
      description: '21 gün — artık bir alışkanlık!',
      requiredStreak: 21,
      rarity: BadgeRarity.epic,
    ),
    BadgeDefinition(
      id: 'one_month',
      emoji: '👑',
      title: 'Ay Sonu Şampiyonu',
      description: '30 gün kesintisiz streak',
      requiredStreak: 30,
      rarity: BadgeRarity.epic,
    ),
    BadgeDefinition(
      id: 'two_months',
      emoji: '🌟',
      title: 'Pixel Efsanesi',
      description: '60 gün ulaşılamaz hedef',
      requiredStreak: 60,
      rarity: BadgeRarity.legendary,
    ),
    BadgeDefinition(
      id: 'one_hundred',
      emoji: '💎',
      title: '100 Gün Elması',
      description: 'Yüz günlük mükemmellik',
      requiredStreak: 100,
      rarity: BadgeRarity.legendary,
    ),
  ];

  /// Mevcut streak ile kazanılmış badge'leri döndür
  static List<BadgeDefinition> unlockedBadges(int streak) {
    return all.where((b) => streak >= b.requiredStreak).toList();
  }

  /// Kilitli badge'ler
  static List<BadgeDefinition> lockedBadges(int streak) {
    return all.where((b) => streak < b.requiredStreak).toList();
  }

  /// Bir sonraki kazanılacak badge
  static BadgeDefinition? nextBadge(int streak) {
    final locked = lockedBadges(streak);
    if (locked.isEmpty) return null;
    locked.sort((a, b) => a.requiredStreak.compareTo(b.requiredStreak));
    return locked.first;
  }
}
