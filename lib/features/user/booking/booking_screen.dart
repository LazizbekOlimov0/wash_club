import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import '../../../core/theme/extensions/theme_extension.dart';
import '../../../../../shared/services/client_session.dart';
import '../../../../../shared/services/supabase_service.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../data/repositories/branches_repository.dart';
import '../../../../shared/services/orders_repository.dart';

// ─────────────────────────────────────────────────────────────
// BOOKING SCREEN — 4 qadam, real Supabase data
// ─────────────────────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  final String? presetBranchId;

  const BookingScreen({super.key, this.presetBranchId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _branchRepo = BranchesRepository.instance;
  final _ordersRepo = OrdersRepository.instance;
  final _session    = ClientSession.instance;

  // ── State ────────────────────────────────────────────────
  int _step = 0;  // 0=Branch 1=Service 2=Time 3=Payment

  List<BranchModel>  _branches  = [];
  List<ServiceModel> _services  = [];
  bool _loadingBranches  = true;
  bool _loadingServices  = false;
  bool _submitting       = false;

  BranchModel?  _selectedBranch;
  ServiceModel? _selectedService;
  final Set<String> _selectedAddons = {};
  DateTime  _selectedDate = DateTime.now();
  String?   _selectedTime;
  String    _paymentMethod = AppConstants.paymentCard;

  // Car selection
  SavedCar? _selectedCar;

  final TextEditingController _promoController = TextEditingController();

  // Time slots — API dan keladi
  List<String> _timeSlots = [];
  Set<String> _bookedSlots = {};
  bool _loadingSlots = false;

  // Default time slots (09:00 - 20:00 har soat)
  static const _defaultTimeSlots = [
    '09:00','10:00','11:00','12:00',
    '13:00','14:00','15:00','16:00',
    '17:00','18:00','19:00','20:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _initCarSelection();
    if (widget.presetBranchId != null) {
      _preselectBranch(widget.presetBranchId!);
    }
  }

  void _preselectBranch(String branchId) async {
    setState(() { _loadingBranches = true; });
    try {
      _branches = await _branchRepo.getBranches(forceRefresh: true);
      if (mounted) {
        final found = _branches.where((b) => b.id == branchId).firstOrNull;
        if (found != null) {
          setState(() {
            _selectedBranch = found;
            _loadingBranches = false;
            _step = 1;
          });
          _loadServices(branchId);
          return;
        }
      }
    } finally {
      if (mounted) setState(() => _loadingBranches = false);
    }
  }

  void _initCarSelection() {
    if (_session.cars.isNotEmpty) _selectedCar = _session.cars.first;
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // ── Load branches ─────────────────────────────────────────
  Future<void> _loadBranches() async {
    setState(() { _loadingBranches = true; });
    try {
      _branches = await _branchRepo.getBranches(forceRefresh: true);
    } finally {
      if (mounted) setState(() => _loadingBranches = false);
    }
  }

  Future<void> _loadServices(String branchId) async {
    setState(() { _loadingServices = true; });
    try {
      _services = await _branchRepo.getServices(branchId);
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  Future<void> _fetchTimeSlots() async {
    if (_selectedBranch == null) return;
    setState(() {
      _loadingSlots = true;
      _timeSlots = [];
      _bookedSlots = {};
      _selectedTime = null;
    });

    try {
      final booked = await SupabaseService.instance.getBookedTimeSlots(
        branchId: _selectedBranch!.id,
        date: _selectedDate,
      );
      if (mounted) {
        setState(() {
          _bookedSlots = booked.toSet();
          _timeSlots = _defaultTimeSlots;
          _loadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _timeSlots = _defaultTimeSlots;
          _loadingSlots = false;
        });
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  void _nextStep() {
    if (_step == 0 && _selectedBranch != null) {
      _loadServices(_selectedBranch!.id);
    }
    if (_step == 1 && _selectedService != null) {
      _fetchTimeSlots();
    }
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
      case 3: return _selectedCar != null || _session.isOnboarded;
      default: return false;
    }
  }

  int get _totalPrice {
    int total = _selectedService?.priceFor(
      _selectedCar?.vehicleCategory ?? AppConstants.vehicleSedan,
    ) ??
        0;
    for (final id in _selectedAddons) {
      final addon = _services.where((s) => s.id == id && s.isAddon).firstOrNull;
      if (addon != null) {
        total += addon.priceFor(
            _selectedCar?.vehicleCategory ?? AppConstants.vehicleSedan);
      }
    }
    return total;
  }

  List<ServiceModel> get _mainServices =>
      _services.where((s) => !s.isAddon).toList();

  List<ServiceModel> get _addonServices =>
      _services.where((s) => s.isAddon).toList();

  // ── Submit order ──────────────────────────────────────────
  Future<void> _submitOrder() async {
    if (_submitting) return;
    if (_selectedBranch == null || _selectedService == null || _selectedTime == null) return;

    // Car check - agar mashina yo'q bo'lsa addCar'ga o'tish
    if (_selectedCar == null && _session.cars.isEmpty) {
      await context.push(UserRoutePath.addCar);
      if (mounted) {
        _initCarSelection();
        setState(() {});
      }
      return;
    }

    if (!_session.isOnboarded) {
      await context.push(UserRoutePath.login);
      return;
    }

    setState(() => _submitting = true);

    try {
      final car = _selectedCar ?? _session.cars.first;

      // scheduledAt hisoblash
      final now = _selectedDate;
      final timeParts = _selectedTime!.split(':');
      final scheduledAt = DateTime(
        now.year, now.month, now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final order = await _ordersRepo.createOrder(
        branchId:        _selectedBranch!.id,
        serviceId:       _selectedService!.id,
        carNumber:       car.plate,
        carModel:        car.displayName,
        totalAmount:     _totalPrice,
        paymentMethod:   _paymentMethod,
        vehicleCategory: car.vehicleCategory,
        scheduledAt:     scheduledAt,
        addonServiceIds: _selectedAddons.toList(),
      );

      if (mounted) {
        _showSuccessDialog(order);
      }
    } catch (e) {
      log(e.toString(), name: 'BookingScreen._submitOrder');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Buyurtma tasdiqlandi!',
              style: TextStyle(
                color: context.colors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.branchName ?? _selectedBranch?.name ?? ''}\n$_selectedTime · ${_formatDate(_selectedDate)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.grey2, fontSize: 14),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetState();
                context.go(UserRoutePath.orders);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.info,
                foregroundColor: context.colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buyurtmalarimga o\'tish'),
            ),
          ),
        ],
      ),
    );
  }

  void _resetState() {
    setState(() {
      _step = 0;
      _selectedBranch = null;
      _selectedService = null;
      _selectedAddons.clear();
      _selectedDate = DateTime.now();
      _selectedTime = null;
      _paymentMethod = AppConstants.paymentCard;
      _timeSlots = [];
      _bookedSlots = {};
      _promoController.clear();
    });
  }

  static const _stepTitles = ['Filial', 'Xizmat', 'Vaqt', "To'lov"];

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
              child: RefreshIndicator(
                onRefresh: _step == 0
                    ? _loadBranches
                    : _step == 1 && _selectedBranch != null
                        ? () => _loadServices(_selectedBranch!.id)
                        : _step == 2
                            ? _fetchTimeSlots
                            : () async {},
                color: colors.info,
                child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepContent(context),
                ),
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
            onTap: _step > 0 ? _prevStep : () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.divider),
              ),
              child: Icon(Icons.arrow_back, color: colors.onSurface, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qadam ${_step + 1} / 4',
                  style: TextStyle(color: colors.grey2, fontSize: 12)),
              Text(_stepTitles[_step],
                  style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildStepContent(BuildContext context) {
    switch (_step) {
      case 0:
        return _loadingBranches
            ? const Center(child: CircularProgressIndicator())
            : _BranchStep(
          branches: _branches,
          selected: _selectedBranch,
          onSelect: (b) => setState(() => _selectedBranch = b),
        );
      case 1:
        return _loadingServices
            ? const Center(child: CircularProgressIndicator())
            : _ServiceStep(
          mainServices:     _mainServices,
          addonServices:    _addonServices,
          selectedService:  _selectedService,
          selectedAddons:   _selectedAddons,
          vehicleCategory:  _selectedCar?.vehicleCategory ??
              AppConstants.vehicleSedan,
          onSelectService:  (s) => setState(() => _selectedService = s),
          onToggleAddon:    (id) => setState(() {
            _selectedAddons.contains(id)
                ? _selectedAddons.remove(id)
                : _selectedAddons.add(id);
          }),
        );
      case 2:
        return _loadingSlots
            ? const Center(child: CircularProgressIndicator())
            : _TimeStep(
          selectedDate:  _selectedDate,
          selectedTime:  _selectedTime,
          timeSlots:     _timeSlots,
          bookedSlots:   _bookedSlots,
          onDateSelect:  (d) {
            setState(() => _selectedDate = d);
            _fetchTimeSlots();
          },
          onTimeSelect:  (t) => setState(() => _selectedTime = t),
        );
      case 3:
        return _PaymentStep(
          branch:         _selectedBranch,
          service:        _selectedService,
          selectedDate:   _selectedDate,
          selectedTime:   _selectedTime,
          paymentMethod:  _paymentMethod,
          totalPrice:     _totalPrice,
          promoController: _promoController,
          cars:           _session.cars,
          selectedCar:    _selectedCar,
          onPaymentMethodChange: (m) =>
              setState(() => _paymentMethod = m),
          onCarSelect:    (car) => setState(() => _selectedCar = car),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final colors = context.colors;
    final isLast = _step == 3;
    final label = isLast
        ? "To'lash · ${_formatPrice(_totalPrice)}"
        : 'Keyingisi';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _canProceed
              ? (isLast ? _submitOrder : _nextStep)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.disabled,
            foregroundColor: colors.onPrimary,
            disabledForegroundColor: colors.disabledContent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _submitting
              ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation(colors.onPrimary)),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward,
                  color: colors.onPrimary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ── FORMAT HELPER ─────────────────────────────────────────────
String _formatPrice(int sum) {
  final s = sum.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} so\'m';
}

// ─────────────────────────────────────────────────────────────
// STEP 1 — BRANCH
// ─────────────────────────────────────────────────────────────
class _BranchStep extends StatelessWidget {
  final List<BranchModel> branches;
  final BranchModel? selected;
  final ValueChanged<BranchModel> onSelect;

  const _BranchStep({
    required this.branches,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (branches.isEmpty) {
      return Center(
        child: Text('Filiallar topilmadi',
            style: TextStyle(color: colors.grey2)),
      );
    }

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
              children: [
                // Placeholder image
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
                          color: b.isActive ? colors.success : colors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b.isActive ? 'Ochiq' : 'Yopiq',
                          style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.name,
                          style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: colors.grey2, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(b.address,
                                style: TextStyle(
                                    color: colors.grey2, fontSize: 12)),
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

// ─────────────────────────────────────────────────────────────
// STEP 2 — SERVICE
// ─────────────────────────────────────────────────────────────
class _ServiceStep extends StatelessWidget {
  final List<ServiceModel> mainServices;
  final List<ServiceModel> addonServices;
  final ServiceModel? selectedService;
  final Set<String> selectedAddons;
  final String vehicleCategory;
  final ValueChanged<ServiceModel> onSelectService;
  final ValueChanged<String> onToggleAddon;

  const _ServiceStep({
    required this.mainServices,
    required this.addonServices,
    required this.selectedService,
    required this.selectedAddons,
    required this.vehicleCategory,
    required this.onSelectService,
    required this.onToggleAddon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    if (mainServices.isEmpty) {
      return Center(
        child: Text('Xizmatlar topilmadi',
            style: TextStyle(color: colors.grey2)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('ASOSIY XIZMAT', colors),
          const SizedBox(height: 10),
          ...mainServices.map((s) {
            final isSelected = selectedService?.id == s.id;
            final price = s.priceFor(vehicleCategory);
            return GestureDetector(
              onTap: () => onSelectService(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: isLight ? 0.08 : 0.15)
                      : cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(s.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          if (s.description.isNotEmpty)
                            Text(s.description,
                                style: TextStyle(
                                    color: colors.grey2, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(_formatPrice(price),
                        style: TextStyle(
                          color: isSelected ? colors.primary : colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            );
          }),
          if (addonServices.isNotEmpty) ...[
            const SizedBox(height: 20),
            _label("QO'SHIMCHA", colors),
            const SizedBox(height: 10),
            ...addonServices.map((a) {
              final isSelected = selectedAddons.contains(a.id);
              return GestureDetector(
                onTap: () => onToggleAddon(a.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: isLight ? 0.06 : 0.12)
                        : cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
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
                          color: isSelected ? colors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                            color: colors.onPrimary, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Text(a.icon,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(a.name,
                                style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Text('+${_formatPrice(a.priceFor(vehicleCategory))}',
                          style: TextStyle(
                              color: colors.info,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _label(String text, dynamic colors) {
    return Text(text,
        style: TextStyle(
            color: colors.grey2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 3 — TIME
// ─────────────────────────────────────────────────────────────
class _TimeStep extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedTime;
  final List<String> timeSlots;
  final Set<String> bookedSlots;
  final ValueChanged<DateTime> onDateSelect;
  final ValueChanged<String> onTimeSelect;

  const _TimeStep({
    required this.selectedDate,
    required this.selectedTime,
    required this.timeSlots,
    required this.bookedSlots,
    required this.onDateSelect,
    required this.onTimeSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    final today = DateTime.now();
    final dates = List.generate(10, (i) => today.add(Duration(days: i)));
    const dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SANA',
              style: TextStyle(
                  color: colors.grey2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
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
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday ? 'BUGUN' : dayNames[(d.weekday - 1) % 7],
                          style: TextStyle(
                              color: isSelected ? colors.onPrimary : colors.grey2,
                              fontSize: 9,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.day.toString(),
                          style: TextStyle(
                              color: isSelected ? colors.onPrimary : colors.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('VAQT',
              style: TextStyle(
                  color: colors.grey2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
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
              final isBooked = bookedSlots.contains(t);
              return GestureDetector(
                onTap: isBooked ? null : () => onTimeSelect(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : isBooked
                            ? colors.disabled
                            : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isBooked
                                ? colors.disabledContent.withValues(alpha: 0.3)
                                : colors.divider,
                            width: 1),
                  ),
                  child: Center(
                    child: Text(t,
                        style: TextStyle(
                            color: isSelected
                                ? colors.onPrimary
                                : isBooked
                                    ? colors.disabledContent
                                    : colors.onSurface,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400)),
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

// ─────────────────────────────────────────────────────────────
// STEP 4 — PAYMENT
// ─────────────────────────────────────────────────────────────
class _PaymentStep extends StatelessWidget {
  final BranchModel? branch;
  final ServiceModel? service;
  final DateTime selectedDate;
  final String? selectedTime;
  final String paymentMethod;
  final int totalPrice;
  final TextEditingController promoController;
  final List<SavedCar> cars;
  final SavedCar? selectedCar;
  final ValueChanged<String> onPaymentMethodChange;
  final ValueChanged<SavedCar> onCarSelect;

  const _PaymentStep({
    required this.branch,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.paymentMethod,
    required this.totalPrice,
    required this.promoController,
    required this.cars,
    required this.selectedCar,
    required this.onPaymentMethodChange,
    required this.onCarSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    final methods = [
      {'id': AppConstants.paymentClick, 'label': 'Click',
        'icon': Icons.touch_app_outlined},
      {'id': AppConstants.paymentPayme, 'label': 'Payme',
        'icon': Icons.payment_outlined},
      {'id': AppConstants.paymentCard, 'label': 'Karta',
        'icon': Icons.credit_card_outlined},
      {'id': AppConstants.paymentCash, 'label': 'Naqd',
        'icon': Icons.money_outlined},
    ];

    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car selection (agar session'da mashina bor bo'lsa)
          if (cars.isNotEmpty) ...[
            _sectionLabel("MASHINA", colors),
            const SizedBox(height: 10),
            ...cars.map((car) {
              final isSelected = selectedCar?.plate == car.plate;
              return GestureDetector(
                onTap: () => onCarSelect(car),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: isLight ? 0.08 : 0.15)
                        : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car_outlined,
                          color: isSelected ? colors.primary : colors.grey2,
                          size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${car.displayName}  ·  ${car.plate}',
                          style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: colors.primary, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          // Payment methods
          _sectionLabel("TO'LOV USULI", colors),
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
                onTap: () => onPaymentMethodChange(m['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: isLight ? 0.08 : 0.15)
                        : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m['icon'] as IconData,
                          color: isSelected ? colors.primary : colors.grey2,
                          size: 18),
                      const SizedBox(width: 6),
                      Text(m['label'] as String,
                          style: TextStyle(
                              color: isSelected
                                  ? colors.onSurface
                                  : colors.grey2,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Promo
          _sectionLabel('PROMOKOD', colors),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.divider),
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
                            hintText: 'Promokod',
                            hintStyle: TextStyle(color: colors.grey2),
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
                    child: Text('Qo\'llash',
                        style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Summary
          _sectionLabel('XULOSA', colors),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              children: [
                _summaryRow('Filial', branch?.name ?? '—', colors),
                const SizedBox(height: 10),
                _summaryRow('Sana va vaqt',
                    selectedTime != null ? '$dateStr · $selectedTime' : '—',
                    colors),
                if (service != null) ...[
                  const SizedBox(height: 10),
                  _summaryRow(service!.name,
                      _formatPrice(service!.priceFor(AppConstants.vehicleSedan)),
                      colors),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: colors.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("To'lash",
                        style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(_formatPrice(totalPrice),
                        style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, dynamic colors) {
    return Text(text,
        style: TextStyle(
            color: colors.grey2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }

  Widget _summaryRow(String label, String value, dynamic colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colors.grey2, fontSize: 13)),
        Flexible(
          child: Text(value,
              style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}