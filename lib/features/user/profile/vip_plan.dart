/// VIP Pass tarif rejalari uchun yagona ma'lumot manbai.
///
/// Profile ekranidagi "teaser" karta va yangi Obunalar ekrani
/// bir xil ma'lumotni ishlatadi — shuning uchun u shu yerda markazlashtirilgan.
class VipPlan {
  /// 1 oylik tarifning oylik narxi (ming so'mda).
  /// Boshqa tariflarning chegirmasi shunga nisbatan hisoblanadi.
  static const int baseMonthlyPriceK = 1190;

  final String name;
  final int months;
  final int perMonthK; // oylik narx, ming so'mda (599 → 599k)
  final int washCount; // paketdagi bepul moyka soni
  final bool isBest;

  const VipPlan({
    required this.name,
    required this.months,
    required this.perMonthK,
    required this.washCount,
    this.isBest = false,
  });

  /// Oylik narx, so'mda.
  int get monthlyPrice => perMonthK * 1000;

  /// Paket davomiyligi (kunlarda).
  int get days => months * 30;

  /// Paketning jami narxi, so'mda.
  int get totalPrice => perMonthK * 1000 * months;

  /// Chegirmasiz "asl" narx (1 oylik narx asosida), so'mda.
  int get originalPrice => baseMonthlyPriceK * 1000 * months;

  /// 1 oylik (eng qimmat) tarifga nisbatan oylik narxdagi chegirma foizi.
  int get discountPercent {
    if (perMonthK >= baseMonthlyPriceK) return 0;
    return ((baseMonthlyPriceK - perMonthK) / baseMonthlyPriceK * 100).round();
  }
}

/// Sonni "3 594 000" ko'rinishida formatlaydi.
String formatPrice(int sum) {
  final s = sum.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Mavjud VIP tariflar ro'yxati.
const List<VipPlan> vipPlans = [
  VipPlan(
    name: 'Premium',
    months: 6,
    perMonthK: 599,
    washCount: 180,
    isBest: true,
  ),
  VipPlan(name: 'Pro', months: 3, perMonthK: 839, washCount: 90),
  VipPlan(
    name: 'Standart',
    months: 1,
    perMonthK: VipPlan.baseMonthlyPriceK,
    washCount: 30,
  ),
];
