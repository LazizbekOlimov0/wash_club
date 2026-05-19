import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extension.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class Branch {
  final String id;
  final String name;
  final String address;
  final String hours;
  final double rating;
  final double distanceKm;
  final bool isOpen;
  final String imageUrl;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.rating,
    required this.distanceKm,
    required this.isOpen,
    required this.imageUrl,
  });
}

class WashService {
  final String id;
  final String name;
  final String description;
  final int priceSum;
  final int durationMin;

  const WashService({
    required this.id,
    required this.name,
    required this.description,
    required this.priceSum,
    required this.durationMin,
  });
}

class AddonService {
  final String id;
  final String name;
  final int priceSum;
  final int durationMin;

  const AddonService({
    required this.id,
    required this.name,
    required this.priceSum,
    required this.durationMin,
  });
}

// ─────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────

final _branches = [
  const Branch(
    id: 'yunusobod',
    name: 'Wash Club Yunusobod',
    address: "Yunusobod tumani, Amir Temur ko'chasi 108",
    hours: '08:00 — 22:00',
    rating: 4.9,
    distanceKm: 1.2,
    isOpen: true,
    imageUrl: '',
  ),
  const Branch(
    id: 'chilonzor',
    name: 'Wash Club Chilonzor',
    address: "Chilonzor tumani, Bunyodkor shoh ko'chasi 14",
    hours: '07:00 — 23:00',
    rating: 4.8,
    distanceKm: 3.8,
    isOpen: true,
    imageUrl: '',
  ),
  const Branch(
    id: 'mirzo',
    name: "Wash Club Mirzo Ulug'bek",
    address: "Mirzo Ulug'bek tumani, Ippodrom ko'chasi 22",
    hours: '08:00 — 21:00',
    rating: 4.7,
    distanceKm: 6.1,
    isOpen: false,
    imageUrl: '',
  ),
];

final _mainServices = [
  const WashService(
    id: 'express',
    name: 'Экспресс',
    description: 'Быстрая внешняя мойка',
    priceSum: 30000,
    durationMin: 20,
  ),
  const WashService(
    id: 'standart',
    name: 'Стандарт',
    description: 'Внешняя + сушка + коврики',
    priceSum: 60000,
    durationMin: 40,
  ),
  const WashService(
    id: 'premium',
    name: 'Премиум',
    description: 'Стандарт + воск + панель',
    priceSum: 120000,
    durationMin: 60,
  ),
  const WashService(
    id: 'detailing',
    name: 'Детейлинг',
    description: 'Полный комплекс ухода',
    priceSum: 350000,
    durationMin: 180,
  ),
];

final _addons = [
  const AddonService(id: 'tires',    name: 'Чернение шин',    priceSum: 15000, durationMin: 5),
  const AddonService(id: 'lights',   name: 'Полировка фар',   priceSum: 25000, durationMin: 10),
  const AddonService(id: 'interior', name: 'Химчистка салона', priceSum: 80000, durationMin: 40),
];

final _timeSlots = [
  '09:00', '10:00', '11:00', '12:00',
  '13:00', '14:00', '15:00', '16:00',
  '17:00', '18:00', '19:00', '20:00',
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _formatPrice(int sum) {
  final s = sum.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} сум';
}

// ─────────────────────────────────────────────
// MAIN BOOKING SCREEN  (4 steps, no car step)
// ─────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0; // 0=Branch 1=Service 2=Time 3=Payment

  Branch?      _selectedBranch;
  WashService? _selectedService;
  final Set<String> _selectedAddons = {};
  DateTime  _selectedDate = DateTime.now();
  String?   _selectedTime;
  String    _paymentMethod = 'card';

  final TextEditingController _promoController =
  TextEditingController(text: 'WASH20');

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  bool get _canProceed {
    switch (_step) {
      case 0: return _selectedBranch != null;
      case 1: return _selectedService != null;
      case 2: return _selectedTime != null;
      case 3: return true;
      default: return false;
    }
  }

  int get _totalPrice {
    int total = _selectedService?.priceSum ?? 0;
    for (final id in _selectedAddons) {
      final a = _addons.firstWhere(
            (a) => a.id == id,
        orElse: () => const AddonService(id: '', name: '', priceSum: 0, durationMin: 0),
      );
      total += a.priceSum;
    }
    return total;
  }

  static const _stepTitles = ['Филиал', 'Услуга', 'Время', 'Оплата'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStepIndicator(context),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepContent(),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _step > 0 ? _prevStep : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.divider),
                boxShadow: Theme.of(context).brightness == Brightness.light
                    ? [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
                    : null,
              ),
              child: Icon(Icons.arrow_back, color: colors.onSurface, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Шаг ${_step + 1} из 4',
                style: TextStyle(color: colors.grey2, fontSize: 12),
              ),
              Text(
                _stepTitles[_step],
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step indicator ──────────────────────────────────────────────
  Widget _buildStepIndicator(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i <= _step;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive ? colors.primary : colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step content ────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _BranchStep(
          branches: _branches,
          selected: _selectedBranch,
          onSelect: (b) => setState(() => _selectedBranch = b),
        );
      case 1:
        return _ServiceStep(
          mainServices: _mainServices,
          addons: _addons,
          selectedService: _selectedService,
          selectedAddons: _selectedAddons,
          onSelectService: (s) => setState(() => _selectedService = s),
          onToggleAddon: (id) => setState(() {
            _selectedAddons.contains(id)
                ? _selectedAddons.remove(id)
                : _selectedAddons.add(id);
          }),
        );
      case 2:
        return _TimeStep(
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          timeSlots: _timeSlots,
          onDateSelect: (d) => setState(() => _selectedDate = d),
          onTimeSelect: (t) => setState(() => _selectedTime = t),
        );
      case 3:
        return _PaymentStep(
          branch: _selectedBranch,
          service: _selectedService,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          paymentMethod: _paymentMethod,
          totalPrice: _totalPrice,
          promoController: _promoController,
          onPaymentMethodChange: (m) => setState(() => _paymentMethod = m),
        );
      default:
        return const SizedBox();
    }
  }

  // ── Bottom bar ──────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final colors = context.colors;
    final label = _step == 3
        ? 'Оплатить ${_formatPrice(_totalPrice)}'
        : 'Далее';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.divider, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _canProceed ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.disabled,
            foregroundColor: colors.onPrimary,
            disabledForegroundColor: colors.disabledContent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, color: colors.onPrimary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 1 — BRANCH
// ─────────────────────────────────────────────

class _BranchStep extends StatelessWidget {
  final List<Branch> branches;
  final Branch? selected;
  final ValueChanged<Branch> onSelect;

  const _BranchStep({
    required this.branches,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: branches.length,
      itemBuilder: (context, i) {
        final b = branches[i];
        final isSelected = selected?.id == b.id;

        return GestureDetector(
          onTap: () => onSelect(b),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? colors.primary : colors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isLight
                  ? [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image / placeholder
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primary.withValues(alpha: 0.18),
                            colors.primary.withValues(alpha: 0.04),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.local_car_wash,
                            color: colors.primary, size: 56),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.isOpen ? colors.success : colors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b.isOpen ? 'Открыто' : 'Закрыто',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Info
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.name,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.star,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            b.rating.toString(),
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: colors.grey2, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              b.address,
                              style: TextStyle(
                                  color: colors.grey2, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: colors.grey2, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            b.hours,
                            style: TextStyle(
                                color: colors.grey2, fontSize: 12),
                          ),
                          const Spacer(),
                          Text(
                            '${b.distanceKm} km',
                            style: TextStyle(
                              color: colors.info,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// STEP 2 — SERVICE
// ─────────────────────────────────────────────

class _ServiceStep extends StatelessWidget {
  final List<WashService> mainServices;
  final List<AddonService> addons;
  final WashService? selectedService;
  final Set<String> selectedAddons;
  final ValueChanged<WashService> onSelectService;
  final ValueChanged<String> onToggleAddon;

  const _ServiceStep({
    required this.mainServices,
    required this.addons,
    required this.selectedService,
    required this.selectedAddons,
    required this.onSelectService,
    required this.onToggleAddon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Card bg: white in light, elevated surface in dark
    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    List<BoxShadow> cardShadow() => isLight
        ? [
      BoxShadow(
        color: colors.shadow.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ]
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            'ОСНОВНАЯ УСЛУГА',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // Main services
          ...mainServices.map((s) {
            final isSelected = selectedService?.id == s.id;
            return GestureDetector(
              onTap: () => onSelectService(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: isLight ? 0.08 : 0.15)
                      : cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [] : cardShadow(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${s.description} · ${s.durationMin} мин',
                            style: TextStyle(
                                color: colors.grey2, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(s.priceSum),
                      style: TextStyle(
                        color: isSelected ? colors.primary : colors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          Text(
            'ДОПОЛНИТЕЛЬНО',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // Addons
          ...addons.map((a) {
            final isSelected = selectedAddons.contains(a.id);
            return GestureDetector(
              onTap: () => onToggleAddon(a.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: isLight ? 0.06 : 0.12)
                      : cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [] : cardShadow(),
                ),
                child: Row(
                  children: [
                    // Checkbox circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.grey2,
                          width: 2,
                        ),
                        color: isSelected
                            ? colors.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(Icons.check,
                          color: colors.onPrimary, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.name,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '+${a.durationMin} мин',
                            style: TextStyle(
                                color: colors.grey2, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${_formatPrice(a.priceSum)}',
                      style: TextStyle(
                        color: colors.info,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 3 — TIME
// ─────────────────────────────────────────────

class _TimeStep extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedTime;
  final List<String> timeSlots;
  final ValueChanged<DateTime> onDateSelect;
  final ValueChanged<String> onTimeSelect;

  const _TimeStep({
    required this.selectedDate,
    required this.selectedTime,
    required this.timeSlots,
    required this.onDateSelect,
    required this.onTimeSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    List<BoxShadow> tileShad() => isLight
        ? [
      BoxShadow(
        color: colors.shadow.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ]
        : [];

    final today = DateTime.now();
    final dates = List.generate(10, (i) => today.add(Duration(days: i)));
    const dayNames = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date label
          Text(
            'ДАТА',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // ── Date chips
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final d = dates[i];
                final isToday = i == 0;
                final isSelected = d.day == selectedDate.day &&
                    d.month == selectedDate.month;
                return GestureDetector(
                  onTap: () => onDateSelect(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 58,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? null
                          : Border.all(color: colors.divider, width: 1),
                      boxShadow: isSelected ? [] : tileShad(),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday
                              ? 'СЕГОДНЯ'
                              : dayNames[(d.weekday - 1) % 7],
                          style: TextStyle(
                            color: isSelected
                                ? colors.onPrimary
                                : colors.grey2,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? colors.onPrimary
                                : colors.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Time label
          Text(
            'ВРЕМЯ',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // ── Time grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (context, i) {
              final t = timeSlots[i];
              final isSelected = t == selectedTime;
              return GestureDetector(
                onTap: () => onTimeSelect(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: colors.divider, width: 1),
                    boxShadow: isSelected ? [] : tileShad(),
                  ),
                  child: Center(
                    child: Text(
                      t,
                      style: TextStyle(
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurface,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 4 — PAYMENT
// ─────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  final Branch? branch;
  final WashService? service;
  final DateTime selectedDate;
  final String? selectedTime;
  final String paymentMethod;
  final int totalPrice;
  final TextEditingController promoController;
  final ValueChanged<String> onPaymentMethodChange;

  const _PaymentStep({
    required this.branch,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.paymentMethod,
    required this.totalPrice,
    required this.promoController,
    required this.onPaymentMethodChange,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    List<BoxShadow> cardShadow() => isLight
        ? [
      BoxShadow(
        color: colors.shadow.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 3),
      )
    ]
        : [];

    final methods = [
      {'id': 'click', 'label': 'Click',     'icon': Icons.touch_app_outlined},
      {'id': 'payme', 'label': 'Payme',     'icon': Icons.payment_outlined},
      {'id': 'card',  'label': 'Карта',     'icon': Icons.credit_card_outlined},
      {'id': 'cash',  'label': 'Наличные',  'icon': Icons.money_outlined},
    ];

    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Payment method
          Text(
            'СПОСОБ ОПЛАТЫ',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.5,
            ),
            itemCount: methods.length,
            itemBuilder: (context, i) {
              final m = methods[i];
              final isSelected = paymentMethod == m['id'];
              return GestureDetector(
                onTap: () =>
                    onPaymentMethodChange(m['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        .withValues(alpha: isLight ? 0.08 : 0.15)
                        : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [] : cardShadow(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m['icon'] as IconData,
                        color: isSelected ? colors.primary : colors.grey2,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? colors.onSurface
                              : colors.grey2,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Promo code
          Text(
            'ПРОМОКОД',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.divider, width: 1),
                    boxShadow: cardShadow(),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.local_offer_outlined,
                          color: colors.grey2, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: promoController,
                          style: TextStyle(
                              color: colors.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Промокод',
                            hintStyle:
                            TextStyle(color: colors.grey2),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Применить',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Summary
          Text(
            'ИТОГ',
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider, width: 1),
              boxShadow: cardShadow(),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Филиал',
                  value: branch?.name ?? '—',
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Дата и время',
                  value: selectedTime != null
                      ? '$dateStr · $selectedTime'
                      : '—',
                ),
                if (service != null) ...[
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: service!.name,
                    value: _formatPrice(service!.priceSum),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: colors.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'К оплате',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatPrice(totalPrice),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGET
// ─────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: colors.grey2, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}