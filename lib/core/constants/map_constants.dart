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
}
