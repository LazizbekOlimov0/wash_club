import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../core/theme/extensions/theme_extension.dart';
import '../../../../../shared/services/client_session.dart';
import '../../../../../shared/services/supabase_service.dart';
import '../../../../../shared/services/promo_service.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/orders_repository.dart';
import 'package:image_picker/image_picker.dart';

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

  // Receipt upload (one-time booking)
  Uint8List? _receiptBytes;
  String? _receiptFileName;
  final ImagePicker _imagePicker = ImagePicker();

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
      case 3: return (_selectedCar != null || _session.cars.isNotEmpty) &&
                    (_hasSubscription || _receiptBytes != null);
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
            content: Text('Promokod noto‘g‘ri: $code'),
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
      await context.push(UserRoutePath.otpLogin);
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = true);

    try {
      final car = _selectedCar ?? _session.cars.first;

      // scheduledAt hisoblash
      final timeParts = _selectedTime!.split(':');
      final scheduledAt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]),
      );

      // Past-time validation
      if (scheduledAt.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("O'tib ketgan vaqtni tanlash mumkin emas"),
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
                content: Text('Kunlik bron limitiga yetdingiz (${AppConstants.dailyBookingLimit} ta)'),
                backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
              ),
            );
          }
          setState(() => _submitting = false);
          return;
        }
      }

      // Receipt upload for one-time booking
      String? receiptUrl;
      if (!_hasSubscription && _receiptBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Iltimos, to\'lov cheki suratini yuklang'),
              backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
            ),
          );
        }
        setState(() => _submitting = false);
        return;
      }

      if (!_hasSubscription && _receiptBytes != null && customerId != null) {
        receiptUrl = await SupabaseService.instance.uploadReceipt(
          customerId: customerId,
          fileBytes: _receiptBytes!,
          fileName: _receiptFileName ?? 'receipt.jpg',
        );
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
        receiptUrl:       receiptUrl,
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
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _pickReceipt() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Fayl 5MB dan kichik bo\'lishi kerak'),
              backgroundColor: Theme.of(context).extension<ApparenceKitColors>()!.error,
            ),
          );
        }
        return;
      }
      setState(() {
        _receiptBytes = bytes;
        _receiptFileName = picked.name;
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
                isMember ? 'Bron qabul qilindi!' : 'Bron yuborildi!',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isMember
                    ? "Moykaga kelganda ushbu QR kodni CRM'dagi QR Scan orqali skaner qildiring."
                    : 'Chek tasdiqlangandan so\'ng broningiz faollashadi.',
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
                    _detailRow(colors, 'Filial', _selectedBranch?.name ?? '—'),
                    _detailRow(colors, 'Xizmat', _selectedService?.name ?? 'Yuvish'),
                    _detailRow(colors, 'Mashina', _selectedCar?.plate ?? _session.cars.first.plate),
                    _detailRow(colors, 'Vaqt', '$_selectedTime · ${_formatDate(_selectedDate)}'),
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
      _receiptBytes = null;
      _receiptFileName = null;
      _hasSubscription = false;
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
          receiptBytes:   _receiptBytes,
          onPickReceipt:  _pickReceipt,
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
              ? 'Bu filialda pullik xizmatlar mavjud emas'
              : 'Xizmatlar topilmadi',
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
                          'FILIAL',
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
                        "O'zgartirish",
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
                          "Istalgan xizmat — atigi 120 000 so'mga",
                          style: TextStyle(
                            color: const Color(0xFFFF8C00),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                          " bron qiling, narxidan qat'i nazar.",
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
              "QO'SHIMCHA XIZMATLAR",
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
        padding: const EdgeInsets.all(14),
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
                  width: 52,
                  height: 52,
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
                const Spacer(),
                // Service name
                Text(
                  service.name,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    service.description,
                    style:
                    TextStyle(color: colors.grey2, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
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
                    "Siz ${_formatPrice(discountAmount)} tejaysiz",
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: colors.grey2, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${service.durationMinutes} daq',
                        style: TextStyle(
                          color: colors.grey2,
                          fontSize: 12,
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
  return "${buf.toString()} so'm";
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
  final Uint8List? receiptBytes;
  final VoidCallback onPickReceipt;

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
    this.receiptBytes,
    required this.onPickReceipt,
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
                    'Obuna orqali — bepul',
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

          // Receipt upload (one-time booking)
          if (!hasSubscription) ...[
            _sectionLabel("TO'LOV CHEKI", colors),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onPickReceipt,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: receiptBytes != null ? colors.success : colors.divider,
                    width: receiptBytes != null ? 2 : 1,
                  ),
                ),
                child: receiptBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(receiptBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_outlined, color: colors.grey2, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'To\'lov cheki suratini yuklang',
                            style: TextStyle(color: colors.grey2, fontSize: 13),
                          ),
                          Text(
                            'Max 5MB',
                            style: TextStyle(color: colors.grey3, fontSize: 11),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],

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
                onTap: onApplyPromo,
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