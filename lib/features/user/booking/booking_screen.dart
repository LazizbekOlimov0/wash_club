import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/i18n/translations.g.dart' show Translations;
import '../../../core/theme/extensions/theme_extension.dart';
import '../../../../../shared/services/client_session.dart';
import '../../../../../shared/services/supabase_service.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/orders_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  PromoResult? _promoResult;

  // Subscription detection
  bool _checkingSubscription = false;
  bool _hasSubscription = false;
  bool _hasActiveBooking = false;

  // Time slots — API dan keladi
  List<String> _timeSlots = [];
  Set<String> _bookedSlots = {};
  bool _loadingSlots = false;

  // Default time slots (09:00 - 23:00 har 30 daqiqa)
  static List<String> get _defaultTimeSlots {
    final slots = <String>[];
    for (var h = 9; h < 23; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
      slots.add('${h.toString().padLeft(2, '0')}:30');
    }
    slots.add('23:00');
    return slots;
  }

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _initCarSelection();
    _checkActiveBooking();
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
          if (!_session.isOnboarded) {
            setState(() { _selectedBranch = found; _loadingBranches = false; });
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.push(UserRoutePath.otpLogin);
              });
            }
            return;
          }
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

  Future<void> _checkActiveBooking() async {
    final customerId = _session.customerId;
    if (customerId == null) return;
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('id')
          .eq('customer_id', customerId)
          .eq('source', 'by_client_app')
          .filter('status', 'in',
              '(queued,pending,pending_payment,confirmed,washing,drying,ready)')
          .limit(1);
      if (mounted) setState(() => _hasActiveBooking = (response as List).isNotEmpty);
    } catch (_) {
      if (mounted) setState(() => _hasActiveBooking = false);
    }
  }

  Future<void> _loadServices(String branchId) async {
    setState(() { _loadingServices = true; _selectedService = null; });
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
      final counts = await SupabaseService.instance.getSlotCounts(
        branchId: _selectedBranch!.id,
        date: _selectedDate,
      );
      if (mounted) {
        // Bitta slotda faqat 1 ta band bo'lsa to'liq band deb belgilaymiz
        final booked = <String>{};
        for (final entry in counts.entries) {
          if (entry.value > 0) booked.add(entry.key);
        }
        setState(() {
          _bookedSlots = booked;
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
    if (_step == 0 && !_session.isOnboarded) {
      context.push(UserRoutePath.otpLogin);
      return;
    }
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
      case 3: return !_hasActiveBooking && (_selectedCar != null || _session.cars.isNotEmpty);
      default: return false;
    }
  }

  int get _totalPrice {
    int total = _selectedService?.priceFor(_vehicleCategory) ?? 0;
    for (final id in _selectedAddons) {
      final addon = _services.where((s) => s.id == id && s.isAddon).firstOrNull;
      if (addon != null) {
        total += addon.priceFor(_vehicleCategory);
      }
    }
    if (_promoResult != null && _promoResult!.ok) {
      total = _promoResult!.total;
    }
    return total;
  }

  void _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      setState(() => _promoResult = null);
      return;
    }
    final result = await SupabaseService.instance.validatePromo(code, _basePrice);
    if (mounted) {
      setState(() => _promoResult = result);
      if (!result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.t.booking.promoInvalid}: $code'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  int get _basePrice {
    int total = _selectedService?.priceFor(_vehicleCategory) ?? 0;
    for (final id in _selectedAddons) {
      final addon = _services.where((s) => s.id == id && s.isAddon).firstOrNull;
      if (addon != null) {
        total += addon.priceFor(_vehicleCategory);
      }
    }
    return total;
  }

  String get _vehicleCategory =>
      _selectedCar?.vehicleCategory ?? AppConstants.vehicleSedan;

  List<ServiceModel> get _mainServices =>
      _services.where((s) => !s.isAddon && s.priceFor(_vehicleCategory) > 0).toList();

  List<ServiceModel> get _addonServices =>
      _services.where((s) => s.isAddon && s.priceFor(_vehicleCategory) > 0).toList();

  // ── Submit order ──────────────────────────────────────────
  Future<void> _submitOrder() async {
    if (_submitting) return;
    if (_selectedBranch == null || _selectedService == null || _selectedTime == null) return;

    // Car check
    if (_selectedCar == null && _session.cars.isEmpty) {
      await context.push(UserRoutePath.addCar);
      if (mounted) {
        _initCarSelection();
        setState(() {});
      }
      return;
    }

    if (!_session.isOnboarded) {
      PendingDestination.set(UserRoutePath.booking);
      await context.push(UserRoutePath.otpLogin);
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = true);

    try {
      final car = _selectedCar ?? _session.cars.first;

      // scheduledAt hisoblash
      final timeParts = _selectedTime!.split(':');
      if (timeParts.length != 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t.booking.timeFormatError)),
          );
        }
        setState(() => _submitting = false);
        return;
      }
      final scheduledAt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]),
      );

      // Past-time validation
      if (scheduledAt.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.t.booking.pastTimeError),
              backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
            ),
          );
        }
        setState(() => _submitting = false);
        return;
      }

      // Check subscription
      final customerId = _session.customerId;
      if (customerId != null && !_checkingSubscription) {
        setState(() => _checkingSubscription = true);
        try {
          final sub = await SupabaseService.instance.getActiveSubscription(customerId);
          _hasSubscription = sub != null && sub.isValid;
        } catch (_) {
          _hasSubscription = false;
        }
        if (mounted) setState(() => _checkingSubscription = false);
      }

      // Daily limit check
      if (customerId != null) {
        final count = await SupabaseService.instance.getDailyBookingCount(
          customerId: customerId,
          date: scheduledAt,
        );
        if (count >= AppConstants.dailyBookingLimit) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${context.t.booking.dailyLimitError} (${AppConstants.dailyBookingLimit})'),
                backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
              ),
            );
          }
          setState(() => _submitting = false);
          return;
        }
      }

      final carModel = car.displayName;
      final promoCode = _promoResult?.ok == true
          ? _promoController.text.trim().toUpperCase()
          : null;
      final carModelWithPromo = promoCode != null
          ? '$carModel|promo:$promoCode'
          : carModel;

      final branchName = _selectedBranch?.name;

      final order = await _ordersRepo.createOrder(
        branchId:         _selectedBranch!.id,
        serviceId:        _selectedService!.id,
        carNumber:        car.plate,
        carModel:         carModelWithPromo,
        totalAmount:      _totalPrice,
        paymentMethod:    _paymentMethod,
        vehicleCategory:  car.vehicleCategory,
        scheduledAt:      scheduledAt,
        addonServiceIds:  _selectedAddons.toList(),
        hasSubscription:  _hasSubscription,
        receiptUrl:       null,
        promoCode:        promoCode,
        branchName:       branchName,
        serviceName:      _selectedService?.name,
      );

      if (mounted) {
        _showSuccessDialog(order);
      }
    } catch (e) {
      log(e.toString(), name: 'BookingScreen._submitOrder');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.t.booking.errorText}: ${e.toString()}'),
            backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _goToAddCar() async {
    await context.push(UserRoutePath.addCar);
    if (mounted) {
      setState(() {
        if (_session.cars.isNotEmpty && _selectedCar == null) {
          _selectedCar = _session.cars.first;
        }
      });
    }
  }

  void _showSuccessDialog(OrderModel order) {
    final isMember = _hasSubscription && order.id.isNotEmpty;
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    final t = context.t; // i18n extension

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
          backgroundColor: colors.onPrimaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isMember ? colors.success.withValues(alpha: 0.15) : colors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMember ? Icons.qr_code_2 : Icons.check_circle_outline,
                  color: isMember ? colors.success : colors.warning,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isMember ? context.t.booking.bookingAccepted : context.t.booking.bookingSubmitted,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isMember
                    ? context.t.booking.bookingQrMsg
                    : context.t.booking.bookingReceiptMsg,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.grey2, fontSize: 13),
              ),

              // QR Code (member only)
              if (isMember) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: order.id,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.home.qrSentToTelegram,
                  style: TextStyle(
                    color: colors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Booking details
              Container(
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.divider),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _detailRow(colors, context.t.booking.branch, _selectedBranch?.name ?? '—'),
                    _detailRow(colors, context.t.booking.service, _selectedService?.name ?? 'Yuvish'),
                    _detailRow(colors, context.t.booking.car, _selectedCar?.plate ?? (_session.cars.isNotEmpty ? _session.cars.first.plate : '—')),
                    _detailRow(colors, context.t.booking.time, '$_selectedTime · ${_formatDate(_selectedDate)}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resetState();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.info,
                        side: BorderSide(color: colors.info),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t.home.newBooking, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resetState();
                        context.go(UserRoutePath.orders);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.info,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t.home.myOrders, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _detailRow(ApparenceKitColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.grey2, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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
      _promoResult = null;
      _promoController.clear();
      _hasSubscription = false;
    });
  }

  static List<String> _stepTitles(Translations t) => [
    t.booking.stepBranch,
    t.booking.stepService,
    t.booking.stepTime,
    t.booking.stepPayment,
  ];

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
            if (_hasActiveBooking) _buildActiveBookingBanner(context),
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
          if (_step > 0) ...[
            GestureDetector(
              onTap: _prevStep,
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
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t.booking.stepLabel.replaceAll('{step}', '${_step + 1}').replaceAll('{total}', '4'),
                  style: TextStyle(color: colors.grey2, fontSize: 12)),
              Text(_stepTitles(context.t)[_step],
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

  Widget _buildActiveBookingBanner(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF0E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF5C88A), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFB8650E), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.t.booking.activeBookingExists,
                style: const TextStyle(
                  color: Color(0xFF8A4F0C),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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
          vehicleCategory:  _vehicleCategory,
          hasRawServices:   _services.isNotEmpty,
          onSelectService:  (s) => setState(() => _selectedService = s),
          onToggleAddon:    (id) => setState(() {
            _selectedAddons.contains(id)
                ? _selectedAddons.remove(id)
                : _selectedAddons.add(id);
          }),
          selectedBranch: _selectedBranch,       // ← yangi
          onChangeBranch: () => setState(() {    // ← yangi
            _step = 0;
            _selectedBranch = null;
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
          basePrice:      _basePrice,
          promoController: _promoController,
          promoResult:    _promoResult,
          onApplyPromo:   _applyPromo,
          cars:           _session.cars,
          selectedCar:    _selectedCar,
          onPaymentMethodChange: (m) =>
              setState(() => _paymentMethod = m),
          onCarSelect:    (car) => setState(() => _selectedCar = car),
          hasSubscription: _hasSubscription,
          onAddCar:       _goToAddCar,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final colors = context.colors;
    final isLast = _step == 3;
    final label = isLast
        ? context.t.booking.pay.replaceAll('{price}', _formatPrice(_totalPrice))
        : context.t.booking.next;

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
  return '${buf.toString()} UZS';
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
        child: Text(context.t.booking.noBranches,
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
                // Branch image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                      child: Image.asset(
                        AppConstants.branchImages[i % AppConstants.branchImages.length],
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(colors),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.isOpenNow ? colors.success : colors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b.isOpenNow ? context.t.booking.open : context.t.booking.closed,
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

  static Widget _buildPlaceholder(ApparenceKitColors colors) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
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
        child:
            Icon(Icons.local_car_wash, color: colors.primary, size: 56),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 2 — SERVICE
// ─────────────────────────────────────────────────────────────
// booking_screen.dart ichidagi _ServiceStep klasini to'liq almashtiring

class _ServiceStep extends StatelessWidget {
  final List<ServiceModel> mainServices;
  final List<ServiceModel> addonServices;
  final ServiceModel? selectedService;
  final Set<String> selectedAddons;
  final String vehicleCategory;
  final bool hasRawServices;
  final ValueChanged<ServiceModel> onSelectService;
  final ValueChanged<String> onToggleAddon;
  final BranchModel? selectedBranch;
  final VoidCallback? onChangeBranch;

  const _ServiceStep({
    required this.mainServices,
    required this.addonServices,
    required this.selectedService,
    required this.selectedAddons,
    required this.vehicleCategory,
    required this.hasRawServices,
    required this.onSelectService,
    required this.onToggleAddon,
    this.selectedBranch,
    this.onChangeBranch,
  });

  // Membership narxi — barcha xizmatlar shu narxga tushadi
  static const int _membershipPrice = 120000;

  /// Xizmat uchun chegirma bormi (membership narxidan qimmat bo'lsa)
  bool _hasDiscount(ServiceModel s) {
    final price = s.priceFor(vehicleCategory);
    return price > _membershipPrice;
  }

  int _discountAmount(ServiceModel s) {
    final price = s.priceFor(vehicleCategory);
    return _hasDiscount(s) ? price - _membershipPrice : 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (mainServices.isEmpty) {
      return Center(
        child: Text(
          hasRawServices
              ? context.t.booking.noPaidServices
              : context.t.booking.noServices,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.grey2),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filial header ──────────────────────────────────
          if (selectedBranch != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isLight
                    ? colors.surface
                    : colors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t.booking.branchLabel,
                          style: TextStyle(
                            color: colors.grey2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedBranch!.name,
                          style: TextStyle(
                            color: colors.onBackground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onChangeBranch != null)
                    GestureDetector(
                      onTap: onChangeBranch,
                      child: Text(
                        context.t.booking.change,
                        style: TextStyle(
                          color: colors.info,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Promo banner ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF8C00).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✨',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                          context.t.booking.anyServicePromo,
                          style: TextStyle(
                            color: const Color(0xFFFF8C00),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                          context.t.booking.anyServicePromo2,
                          style: TextStyle(
                            color: colors.onBackground
                                .withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Main services — 2 column grid ──────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: mainServices.length,
            itemBuilder: (context, i) {
              final s = mainServices[i];
              return _ServiceCard(
                service: s,
                isSelected: selectedService?.id == s.id,
                vehicleCategory: vehicleCategory,
                membershipPrice: _membershipPrice,
                hasDiscount: _hasDiscount(s),
                discountAmount: _discountAmount(s),
                isLight: isLight,
                onTap: () => onSelectService(s),
              );
            },
          ),

          // ── Addons ─────────────────────────────────────────
          if (addonServices.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              context.t.booking.additionalServices,
              style: TextStyle(
                color: colors.grey2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            ...addonServices.map((a) {
              final isSelected = selectedAddons.contains(a.id);
              final cardBg = isLight
                  ? colors.surface
                  : colors.onPrimaryContainer;
              return GestureDetector(
                onTap: () => onToggleAddon(a.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(
                        alpha: isLight ? 0.06 : 0.12)
                        : cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.divider,
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
                            color: isSelected
                                ? colors.primary
                                : colors.grey2,
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
                        child: Row(
                          children: [
                            Text(a.icon,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              a.name,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+${_formatPrice(a.priceFor(vehicleCategory))}',
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
        ],
      ),
    );
  }
}

// ── Service card widget ────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final String vehicleCategory;
  final int membershipPrice;
  final bool hasDiscount;
  final int discountAmount;
  final bool isLight;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.vehicleCategory,
    required this.membershipPrice,
    required this.hasDiscount,
    required this.discountAmount,
    required this.isLight,
    required this.onTap,
  });

  // Icon background rangi — xizmat turiga qarab
  Color _iconBg(BuildContext context) {
    final colors = context.colors;
    // Emoji icon'ga qarab rang tanlash
    final icon = service.icon;
    if (icon.contains('⚡') || icon.contains('🔥') || icon.contains('⚡️')) {
      return const Color(0xFFFF8C00).withValues(alpha: 0.18);
    }
    if (icon.contains('💧') || icon.contains('🌊') || icon.contains('✨')) {
      return colors.info.withValues(alpha: 0.15);
    }
    if (icon.contains('💎') || icon.contains('👑')) {
      return const Color(0xFF22C55E).withValues(alpha: 0.18);
    }
    return colors.primary.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final originalPrice = service.priceFor(vehicleCategory);
    final cardBg =
    isLight ? colors.surface : colors.onPrimaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: isLight ? 0.08 : 0.15)
              : cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? colors.primary : colors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _iconBg(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      service.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Service name
                Text(
                  service.name,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    service.description,
                    style:
                    TextStyle(color: colors.grey2, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                // Price row
                if (hasDiscount) ...[
                  // Eski narx — strikethrough
                  Text(
                    _formatPrice(originalPrice),
                    style: TextStyle(
                      color: colors.grey2,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: colors.grey2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatPrice(membershipPrice),
                        style: const TextStyle(
                          color: Color(0xFFFF8C00),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.t.booking.savedAmount.replaceAll('{amount}', _formatPrice(discountAmount)),
                    style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatPrice(originalPrice),
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
                // Vaqt (duration) — agar service'da bo'lsa
                if (service.durationMinutes != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time,
                          color: colors.grey2, size: 12),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          context.t.booking.minutes.replaceAll('{minutes}', '${service.durationMinutes}'),
                          style: TextStyle(
                            color: colors.grey2,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Discount badge — top right
            if (hasDiscount)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥',
                          style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Text(
                        '-${_formatShortPrice(discountAmount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Price formatters ───────────────────────────────────────────────
String _formatShortPrice(int sum) {
  // "10 000 so'm" o'rniga "-10 000 so'm" badge uchun
  final s = sum.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} UZS";
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
    final dates = List.generate(5, (i) => today.add(Duration(days: i)));
    final dayNames = [context.t.booking.dayMon, context.t.booking.dayTue, context.t.booking.dayWed, context.t.booking.dayThu, context.t.booking.dayFri, context.t.booking.daySat, context.t.booking.daySun];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.booking.sana,
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
                          isToday ? context.t.booking.today : dayNames[(d.weekday - 1) % 7],
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
          Text(context.t.booking.timeLabel,
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
              final tHour = int.parse(t.split(':')[0]);
              final now = DateTime.now();
              final isToday = selectedDate.year == now.year &&
                  selectedDate.month == now.month &&
                  selectedDate.day == now.day;
              final slotTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day, tHour);
              final isPast = isToday && slotTime.isBefore(now);
              final isSelected = t == selectedTime;
              final isBooked = bookedSlots.contains(t);
              final isDisabled = isBooked || isPast;
              return GestureDetector(
                onTap: isDisabled ? null : () => onTimeSelect(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : isDisabled
                            ? colors.disabled
                            : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDisabled
                                ? colors.disabledContent.withValues(alpha: 0.3)
                                : colors.divider,
                            width: 1),
                  ),
                  child: Center(
                    child: Text(t,
                        style: TextStyle(
                            color: isSelected
                                ? colors.onPrimary
                                : isDisabled
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
  final int basePrice;
  final TextEditingController promoController;
  final PromoResult? promoResult;
  final VoidCallback onApplyPromo;
  final List<SavedCar> cars;
  final SavedCar? selectedCar;
  final ValueChanged<String> onPaymentMethodChange;
  final ValueChanged<SavedCar> onCarSelect;
  final bool hasSubscription;
  final VoidCallback onAddCar;

  const _PaymentStep({
    required this.branch,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.paymentMethod,
    required this.totalPrice,
    required this.basePrice,
    required this.promoController,
    required this.promoResult,
    required this.onApplyPromo,
    required this.cars,
    required this.selectedCar,
    required this.onPaymentMethodChange,
    required this.onCarSelect,
    this.hasSubscription = false,
    required this.onAddCar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? colors.surface : colors.onPrimaryContainer;

    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription status
          if (hasSubscription)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: isLight ? 0.08 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: colors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.t.booking.membershipFree,
                    style: TextStyle(
                      color: colors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          if (hasSubscription) const SizedBox(height: 20),

          // Car selection (agar session'da mashina bor bo'lsa)
          if (cars.isNotEmpty) ...[
            _sectionLabel(context.t.booking.carLabel, colors),
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
          ] else ...[
            _sectionLabel(context.t.booking.carLabel, colors),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onAddCar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: isLight ? 0.05 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: colors.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      context.t.booking.addCar,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Payment method — only cash at car wash
          _sectionLabel(context.t.booking.paymentLabel, colors),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.primary, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.money_outlined, color: colors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t.booking.cash,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.t.booking.payAtCarWash(price: _formatPrice(totalPrice)),
                            style: TextStyle(color: colors.grey2, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        context.t.booking.unpaidLabel,
                        style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.t.booking.payAtCarWashDesc,
                  style: TextStyle(color: colors.grey2, fontSize: 12, height: 1.4),
                ),
              ],
            ),
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
                            hintText: context.t.booking.promoCode,
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
                onTap: onApplyPromo,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(context.t.booking.apply,
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
          _sectionLabel(context.t.booking.summaryLabel, colors),
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
                _summaryRow(context.t.booking.branch, branch?.name ?? '—', colors),
                const SizedBox(height: 10),
                _summaryRow(context.t.booking.summaryDateTime,
                    selectedTime != null ? '$dateStr · $selectedTime' : '—',
                    colors),
                if (service != null) ...[
                  const SizedBox(height: 10),
                  _summaryRow(service!.name,
                      _formatPrice(basePrice),
                      colors),
                ],
                if (promoResult != null && promoResult!.ok) ...[
                  const SizedBox(height: 10),
                  _summaryRow(
                    'Promokod (${promoResult!.label})',
                    '-${_formatPrice(promoResult!.discount)}',
                    colors,
                    isDiscount: true,
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: colors.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.t.booking.stepPayment,
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

  Widget _summaryRow(String label, String value, dynamic colors, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDiscount ? colors.success : colors.grey2, fontSize: 13)),
        Flexible(
          child: Text(value,
              style: TextStyle(
                  color: isDiscount ? colors.success : colors.onSurface,
                  fontSize: 13,
                  fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500),
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}