/// Xarita tile provayderi uchun konstantalar.
///
/// MapTiler API kaliti va Streets uslubi URL'i bir joyda saqlanadi,
/// shunda kelajakda boshqa uslubga (Dark, Satellite, ...) o'tish uchun
/// faqat shu fayldagi URL'ni almashtirish kifoya.
class MapConstants {
  MapConstants._();

  static const String mapTilerApiKey = 'OozcOHMmFCfDBZyUTIYl';

  /// MapTiler "Bright" uslubi (och / light fon, Google Maps'ga o'xshash).
  ///
  /// `streets-v2` ga qaraganda kamroq mayda label/yo'l kodi ko'rsatadi —
  /// ko'chalar/mahallalar tozaroq o'qiladi. `{r}` placeholder'i retina (@2x)
  /// displeylarda yuqori aniqlikdagi tile'larni so'raydi.
  static const String mapTilerStreetsUrl =
      'https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}{r}.png?key=$mapTilerApiKey';

  /// Google Maps API kaliti uchun placeholder.
  ///
  /// Google Maps Flutter plagin'i kalitni Dart tomonda EMAS, balki native
  /// tomonda o'qiydi. Haqiqiy kalit gitignored fayllarda saqlanadi:
  ///   - `.env` (Android build.gradle.kts o'qiydi)
  ///   - `ios/Flutter/GoogleMapsKeys.xcconfig` (iOS xcconfig include qiladi)
  ///
  /// Bu konstanta faqat hujjat/referens uchun saqlanadi.
  static const String googleMapsApiKeyPlaceholder = 'GOOGLE_MAPS_API_KEY_PLACEHOLDER';
}
