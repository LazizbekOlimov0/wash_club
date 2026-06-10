/// Promo kod xizmati.
/// Promo kodlar backenddan kelmaydi — hardcoded.
/// Kelajakda DB dan o‘qish uchun SupabaseService'ga o‘tkaziladi.
class PromoResult {
  final bool ok;
  final int discount;
  final int total;
  final String label;

  const PromoResult({
    required this.ok,
    required this.discount,
    required this.total,
    required this.label,
  });

  const PromoResult.invalid()
      : ok = false,
        discount = 0,
        total = 0,
        label = '';
}

class PromoService {
  PromoService._();

  static const _promos = [
    _Promo(code: 'WASH20', discount: 0.2, label: '20% chegirma'),
    _Promo(code: 'FRIEND', discount: 0.15, label: '15% do‘st chegirmasi'),
    _Promo(code: 'FIRST', discount: 0.25, label: '25% birinchi buyurtma'),
  ];

  static PromoResult apply(String code, int total) {
    final input = code.trim().toUpperCase();
    final promo = _promos.where((p) => p.code == input).firstOrNull;
    if (promo == null) return const PromoResult.invalid();
    final discount = (total * promo.discount).round();
    return PromoResult(
      ok: true,
      discount: discount,
      total: total - discount,
      label: promo.label,
    );
  }
}

class _Promo {
  final String code;
  final double discount;
  final String label;

  const _Promo({
    required this.code,
    required this.discount,
    required this.label,
  });
}
