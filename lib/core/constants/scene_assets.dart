// lib/core/constants/scene_assets.dart
//
// Sahne sistemi:
// - Her sahnenin birden fazla "seviyesi" var
// - 3-4 günlük tüm habitler tamamlanınca sahne bir üst seviyeye yükseliyor
// - Assetleri assets/images/scenes/ klasörüne koyuyorsun
//
// Klasör yapısı önerisi:
//   assets/images/scenes/fountain_0.png  ← kuru/harap çeşme
//   assets/images/scenes/fountain_1.png  ← normal çeşme (mevcut)
//   assets/images/scenes/fountain_2.png  ← çiçekli çeşme
//   assets/images/scenes/fountain_3.png  ← büyülü çeşme
//
// Birden fazla sahne tipi ekleyebilirsin (bahçe, şehir, orman, vb.)

enum SceneType {
  fountain,  // Çeşme (resimde görülen)
  garden,    // Bahçe
  town,      // Kasaba
  forest,    // Orman
  // Yeni sahne tipleri buraya eklenebilir
}

class SceneLevel {
  final int level;           // 0 = başlangıç, arttıkça daha güzel
  final String assetPath;
  final String description;  // Kullanıcıya gösterilecek açıklama
  final int requiredStreak;  // Kaç günlük streak gerekli

  const SceneLevel({
    required this.level,
    required this.assetPath,
    required this.description,
    required this.requiredStreak,
  });
}

class SceneAssets {
  // Her sahne tipi için seviyeleri tanımla
  static const Map<SceneType, List<SceneLevel>> scenes = {
    SceneType.fountain: [
      SceneLevel(
        level: 0,
        assetPath: 'assets/images/scenes/fountain.png',
        description: 'Terk edilmiş çeşme...',
        requiredStreak: 0,
      ),
      SceneLevel(
        level: 1,
        assetPath: 'assets/images/scenes/fish.png',
        description: 'Çeşme akmaya başladı!',
        requiredStreak: 3,
      ),
      SceneLevel(
        level: 2,
        assetPath: 'assets/images/scenes/cristal.png',
        description: 'Çevresi çiçeklendi 🌸',
        requiredStreak: 7,
      ),
      SceneLevel(
        level: 3,
        assetPath: 'assets/images/scenes/carrousel.png',
        description: 'Büyülü çeşme! ✨',
        requiredStreak: 14,
      ),
    ],
    // Diğer sahneler buraya eklenecek
  };

  /// Mevcut streak'e göre hangi sahne seviyesinin gösterileceğini döndürür
  static SceneLevel getCurrentScene(SceneType type, int currentStreak) {
    final levels = scenes[type] ?? [];
    SceneLevel current = levels.first;

    for (final level in levels) {
      if (currentStreak >= level.requiredStreak) {
        current = level;
      }
    }
    return current;
  }

  /// Bir sonraki seviyeye ne kadar kaldığını döndürür
  static int? streakNeededForNext(SceneType type, int currentStreak) {
    final levels = scenes[type] ?? [];
    for (final level in levels) {
      if (level.requiredStreak > currentStreak) {
        return level.requiredStreak - currentStreak;
      }
    }
    return null; // Max seviyeye ulaşıldı
  }
}
