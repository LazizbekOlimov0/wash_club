import '../services/supabase_service.dart';

/// Branches va services'larni boshqaruvchi repository.
/// In-memory cache bilan — har safar API chaqirilmaydi.
class BranchesRepository {
  BranchesRepository._();
  static final BranchesRepository instance = BranchesRepository._();

  final SupabaseService _api = SupabaseService.instance;

  List<BranchModel> _branches = [];
  DateTime? _lastFetched;

  static const _cacheDuration = Duration(minutes: 10);

  bool get _isStale =>
      _lastFetched == null ||
      DateTime.now().difference(_lastFetched!) > _cacheDuration;

  // ── Get branches ──────────────────────────────────────────
  Future<List<BranchModel>> getBranches({bool forceRefresh = false}) async {
    if (!forceRefresh && !_isStale && _branches.isNotEmpty) {
      return _branches;
    }
    _branches = await _api.getBranches();
    _lastFetched = DateTime.now();
    return _branches;
  }

  Future<BranchModel?> getBranch(String id, {bool forceRefresh = false}) async {
    // Cache'dan qidirish
    if (!forceRefresh) {
      final cached = _branches.where((b) => b.id == id).firstOrNull;
      if (cached != null) return cached;
    }
    return _api.getBranch(id);
  }

  // ── Services ──────────────────────────────────────────────
  Future<List<ServiceModel>> getServices(String branchId) async {
    // Branch cache'da services bor bo'lsa shunikini qaytaramiz
    final branch = _branches.where((b) => b.id == branchId).firstOrNull;
    if (branch != null && branch.services.isNotEmpty) {
      return branch.services;
    }
    return _api.getServices(branchId);
  }

  void invalidate() {
    _branches = [];
    _lastFetched = null;
  }
}
