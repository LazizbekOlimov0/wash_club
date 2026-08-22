/// Xarita tile provayderi uchun konstantalar.
///
/// MapTiler API kaliti va Streets uslubi URL'i bir joyda saqlanadi,
/// shunda kelajakda boshqa uslubga (Dark, Satellite, ...) o'tish uchun
/// faqat shu fayldagi URL'ni almashtirish kifoya.
class MapConstants {
  MapConstants._();

  static const String mapTilerApiKey = 'OozcOHMmFCfDBZyUTIYl';

  /// MapTiler "Streets" uslubi (och / light fon).
  ///
  /// `{r}` placeholder'i retina (@2x) displeylarda yuqori aniqlikdagi
  /// tile'larni so'raydi — yozuvlar kichkina/qirrali ko'rinmasligi uchun.
  static const String mapTilerStreetsUrl =
      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}{r}.png?key=$mapTilerApiKey';
}
