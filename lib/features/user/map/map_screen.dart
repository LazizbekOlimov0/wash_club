import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/i18n/extensions/i18n_extension.dart';
import '../../../../core/constants/map_constants.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../config/router/router.dart';
import 'widgets/branch_info_card.dart';

class MapScreen extends StatefulWidget {
  final String? focusBranchId;

  const MapScreen({super.key, this.focusBranchId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin {
  final _mapController = MapController();
  final _repo = BranchesRepository.instance;
  List<BranchModel> _branches = [];
  bool _loading = true;
  bool _locating = false;
  LatLng? _userPosition;
  List<LatLng>? _routePoints;
  bool _routing = false;
  String _selectedFilter = 'all';
  BranchModel? _selectedBranch;
  bool _showList = false;
  bool _listPanelVisible = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _listCtrl;
  late Animation<Offset> _listSlideAnim;

  static const _defaultCenter = LatLng(41.2995, 69.2401); // Toshkent

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _listSlideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _listCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _getBranches();
    _fetchUserLocationSilently();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _listCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getBranches() async {
    try {
      _branches = await _repo.getBranches();
      if (mounted && widget.focusBranchId != null) {
        _focusOnBranch(widget.focusBranchId!);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _focusOnBranch(String branchId) {
    final b = _branches.where((x) => x.id == branchId).firstOrNull;
    if (b == null || b.latitude == null || b.longitude == null) return;
    final latLng = LatLng(b.latitude!, b.longitude!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(latLng, 15.0);
    });
  }

  Future<void> _fetchUserLocationSilently() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (mounted) {
        setState(() => _userPosition = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {
      // Joylashuvni jimgina aniqlab bo'lmadi — masofa hisoblash ixtiyoriy.
    }
  }

  Future<void> _goToMyLocation() async {
    if (mounted) setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        setState(() => _locating = false);
        _showLocationDialog();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied && mounted) {
          setState(() => _locating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever && mounted) {
        setState(() => _locating = false);
        _showPermissionDialog();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        _mapController.move(userLatLng, 14.0);
        setState(() { _userPosition = userLatLng; _locating = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.t.map.locationServiceOff),
        content: Text(context.t.map.locationServiceOffDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t.settings.mapClose)),
          TextButton(
            onPressed: () { Navigator.pop(context); Geolocator.openLocationSettings(); },
            child: Text(context.t.settings.mapOpenSettings),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.t.settings.mapBlocked),
        content: Text(context.t.settings.mapBlockedDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t.settings.mapClose)),
          TextButton(
            onPressed: () { Navigator.pop(context); Geolocator.openAppSettings(); },
            child: Text(context.t.settings.mapOpenSettings),
          ),
        ],
      ),
    );
  }

  void _setListVisible(bool visible) {
    if (visible) {
      setState(() {
        _showList = true;
        _listPanelVisible = true;
      });
      _listCtrl.forward();
    } else {
      setState(() => _showList = false);
      _listCtrl.reverse().then((_) {
        if (mounted) setState(() => _listPanelVisible = false);
      });
    }
  }

  void _toggleList() => _setListVisible(!_showList);

  double get _mapZoom => _userPosition != null ? 13.5 : 11.0;
  LatLng get _mapCenter => _userPosition ?? _defaultCenter;

  // ── Distance / time ────────────────────────────────────────────
  double _distanceKm(LatLng a, LatLng b) =>
      const Distance().as(LengthUnit.Kilometer, a, b);

  String _distanceText(LatLng a, LatLng b) {
    final km = _distanceKm(a, b);
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  // ── Filters ────────────────────────────────────────────────────
  List<BranchModel> get _filteredBranches {
    switch (_selectedFilter) {
      case 'premium':
        return _branches.where((b) => b.services.any((s) =>
            s.name.toLowerCase().contains('premium') ||
            s.icon.contains('💎') ||
            s.icon.contains('👑'))).toList();
      case '24_7':
        return _branches.where((b) => b.is24_7).toList();
      case 'carwash':
        return _branches.where((b) => b.services.any((s) {
          final n = s.name.toLowerCase();
          return n.contains('yuvish') ||
              n.contains('avtomoyka') ||
              n.contains('moyka') ||
              n.contains('wash') ||
              s.icon.contains('🚗') ||
              s.icon.contains('🧽') ||
              s.icon.contains('💧');
        })).toList();
      default:
        return _branches;
    }
  }

  // ── Simple grid-based clustering ────────────────────────────────
  List<_Cluster> _buildClusters() {
    final branches = _filteredBranches;
    if (branches.isEmpty) return [];

    final withCoords = branches
        .where((b) => b.latitude != null && b.longitude != null)
        .toList();
    if (withCoords.isEmpty) return [];

    // Determine cluster cell size in lat/lng degrees based on current zoom
    final zoom = _mapController.camera.zoom;
    // Approx: at zoom 10, 1 cell ≈ 0.05 degrees; scale inversely with zoom
    final cellDeg = 0.8 / pow(2, zoom - 5);

    final groups = <String, List<BranchModel>>{};
    for (final b in withCoords) {
      final key = '${(b.latitude! / cellDeg).round()}_${(b.longitude! / cellDeg).round()}';
      groups.putIfAbsent(key, () => []).add(b);
    }

    return groups.entries.map((e) {
      final avgLat = e.value.map((b) => b.latitude!).reduce((a, b) => a + b) / e.value.length;
      final avgLng = e.value.map((b) => b.longitude!).reduce((a, b) => a + b) / e.value.length;
      return _Cluster(LatLng(avgLat, avgLng), e.value);
    }).toList();
  }

  // ── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    final clusters = _buildClusters();

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: _mapZoom,
              minZoom: 5,
              maxZoom: 22,
              onTap: (_, real) {
                if (_showList) {
                  _setListVisible(false);
                } else if (_selectedBranch != null) {
                  setState(() => _selectedBranch = null);
                }
              },
            ),
            children: [
              // MapTiler Bright — och (light) fon, Google Maps'ga o'xshash
              TileLayer(
                urlTemplate: MapConstants.mapTilerStreetsUrl,
                userAgentPackageName: 'com.washclub.app',
                retinaMode: RetinaMode.isHighDensity(context),
                maxNativeZoom: 22,
                maxZoom: 22,
                tileProvider: _RetryingNetworkTileProvider(),
              ),
              // Marshrut chizig'i (OSRM polyline)
              if (_routePoints != null && _routePoints!.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      strokeWidth: 5,
                      color: colors.info,
                    ),
                  ],
                ),
              // Branch markers (teardrop style, tanlanganda label chiqadi)
              MarkerLayer(
                markers: clusters.map((cluster) {
                  final isCluster = cluster.branches.length > 1;
                  final b = cluster.branches.first;
                  final selected = !isCluster && _selectedBranch?.id == b.id;
                  return Marker(
                    point: cluster.center,
                    width: isCluster ? 48 : (selected ? 160 : 36),
                    height: isCluster ? 48 : (selected ? 90 : 42),
                    alignment: isCluster ? Alignment.center : Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => _onClusterTap(cluster, colors),
                      child: isCluster
                          ? _buildClusterWidget(cluster.branches.length, colors)
                          : _buildBranchMarker(b, colors, selected: selected),
                    ),
                  );
                }).toList(),
              ),
              // User location with pulse
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      width: 70,
                      height: 70,
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) => _buildUserMarker(colors),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Header: back + title + filter chips
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: _btnDecoration(colors),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(t.map.title, style: TextStyle(color: colors.onBackground, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('all', t.map.filterAll, colors),
                        _buildFilterChip('premium', t.map.filterPremium, colors),
                        _buildFilterChip('24_7', t.map.filter247, colors),
                        _buildFilterChip('carwash', t.map.filterCarWash, colors),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Zoom controls + my location (bottom-right)
          Positioned(
            right: 14,
            bottom: 110,
            child: Column(
              children: [
                _ctrlBtn(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), colors),
                const SizedBox(height: 6),
                _ctrlBtn(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), colors),
                const SizedBox(height: 10),
                _ctrlBtn(Icons.my_location, _goToMyLocation, colors),
              ],
            ),
          ),

          // List toggle button
          Positioned(
            left: 16,
            right: 16,
            bottom: 36,
            child: Center(
              child: GestureDetector(
                onTap: _toggleList,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.mapBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_showList ? Icons.map : Icons.list, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _showList ? t.map.showMap : t.map.showList,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Branch list panel
          if (_listPanelVisible) _buildBranchListPanel(colors, _listSlideAnim),

          // Selected branch panel (animated)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _selectedBranch != null
                  ? BranchInfoCard(
                      branch: _selectedBranch!,
                      userLat: _userPosition?.latitude,
                      userLng: _userPosition?.longitude,
                      onClose: () => setState(() => _selectedBranch = null),
                      onRoute: () {
                        final b = _selectedBranch!;
                        setState(() => _selectedBranch = null);
                        _fetchRoute(b);
                      },
                      onBook: () {
                        final b = _selectedBranch!;
                        setState(() => _selectedBranch = null);
                        context.go('${UserRoutePath.booking}?branchId=${b.id}');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Loading
          if (_loading || _locating || _routing)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(colors.info))),
                    const SizedBox(width: 10),
                    Text(_locating ? t.map.loadingLocation : t.map.loadingBranches, style: TextStyle(color: colors.grey2, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Cluster tap → tanlash yoki zoom ─────────────────────────────
  void _onClusterTap(_Cluster cluster, ApparenceKitColors colors) {
    if (cluster.branches.length == 1) {
      _selectBranch(cluster.branches.first);
    } else {
      // Zoom into cluster
      setState(() => _selectedBranch = null);
      final bounds = LatLngBounds.fromPoints(cluster.branches.map((b) => LatLng(b.latitude!, b.longitude!)).toList());
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)));
    }
  }

  void _selectBranch(BranchModel b) {
    setState(() => _selectedBranch = b);
  }

  // ── Route (OSRM) ───────────────────────────────────────────────
  // OSRM bepul demo serveri production yuklama uchun mo'ljallanmagan
  // (rate limit bor). Hozircha MVP/test uchun ishlatiladi; kelajakda
  // o'z OSRM serveri yoki boshqa provayderga o'tish kerak.
  Future<void> _fetchRoute(BranchModel branch) async {
    final user = _userPosition;
    final bLat = branch.latitude;
    final bLng = branch.longitude;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.map.locationError)),
      );
      return;
    }
    if (bLat == null || bLng == null) return;

    setState(() => _routing = true);

    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${user.longitude},${user.latitude};$bLng,$bLat'
          '?overview=full&geometries=geojson';
      final resp = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        final route = routes?.firstOrNull;
        final geometry = route is Map<String, dynamic> ? route['geometry'] : null;
        final coords = geometry is Map<String, dynamic>
            ? geometry['coordinates'] as List<dynamic>?
            : null;
        if (coords != null && coords.length >= 2) {
          final points = coords
              .map((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
          if (mounted) {
            setState(() => _routePoints = points);
            _fitRouteBounds(points);
          }
          return;
        }
      }
      _fallbackStraightLine(user, LatLng(bLat, bLng));
    } catch (_) {
      _fallbackStraightLine(user, LatLng(bLat, bLng));
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  void _fallbackStraightLine(LatLng user, LatLng branch) {
    setState(() => _routePoints = [user, branch]);
    _fitRouteBounds([user, branch]);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.map.routeFailed)),
      );
    }
  }

  void _fitRouteBounds(List<LatLng> points) {
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  // ── Markers ─────────────────────────────────────────────────────
  Widget _buildBranchMarker(BranchModel b, ApparenceKitColors colors, {bool selected = false}) {
    if (selected) return _buildSelectedBranchMarker(b, colors);
    return _buildTeardropMarker(colors);
  }

  Widget _buildSelectedBranchMarker(BranchModel b, ApparenceKitColors colors) {
    final user = _userPosition;
    String? distanceText;
    if (user != null && b.latitude != null && b.longitude != null) {
      distanceText = _distanceText(user, LatLng(b.latitude!, b.longitude!));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                b.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              if (b.rating != null) ...[
                const SizedBox(height: 2),
                Text(
                  '★ ${b.rating!.toStringAsFixed(1)}${distanceText != null ? ' · $distanceText' : ''}',
                  style: const TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildTeardropMarker(colors, color: colors.info, scale: 1.25),
      ],
    );
  }

  Widget _buildTeardropMarker(ApparenceKitColors colors, {Color? color, double scale = 1.0}) {
    return CustomPaint(
      painter: _TeardropPainter(color ?? colors.info),
      size: Size(36 * scale, 42 * scale),
    );
  }

  Widget _buildClusterWidget(int count, ApparenceKitColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.info,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: colors.info.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildUserMarker(ApparenceKitColors colors) {
    final size = 28 + (16 * _pulseAnim.value);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.info.withValues(alpha: 0.15 * _pulseAnim.value),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.info,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: colors.info.withValues(alpha: 0.5), blurRadius: 6)],
          ),
        ),
      ],
    );
  }

  // ── Controls ────────────────────────────────────────────────────
  BoxDecoration _btnDecoration(ApparenceKitColors colors) => BoxDecoration(
    color: colors.mapBadge,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _ctrlBtn(IconData icon, VoidCallback onTap, ApparenceKitColors colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: _btnDecoration(colors),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, ApparenceKitColors colors) {
    final selected = _selectedFilter == key;
    final icon = switch (key) {
      'premium' => Icons.workspace_premium,
      '24_7' => Icons.schedule,
      'carwash' => Icons.directions_car_outlined,
      _ => Icons.pin_drop_outlined,
    };
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.info : colors.mapBadge,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.info : colors.grey2.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Branch list panel ───────────────────────────────────────────
  Widget _buildBranchListPanel(
      ApparenceKitColors colors, Animation<Offset> slide) {
    final withCoords = _filteredBranches.where((b) => b.latitude != null && b.longitude != null).toList();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: SlideTransition(
        position: slide,
        child: GestureDetector(
          onTap: () {}, // block taps through
          child: Container(
          decoration: BoxDecoration(
            color: colors.mapBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.grey2, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(context.t.home.branches, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: withCoords.length,
                  itemBuilder: (_, i) {
                    final b = withCoords[i];
                    return GestureDetector(
                      onTap: () { _setListVisible(false); _mapController.move(LatLng(b.latitude!, b.longitude!), 15.0); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.mapSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: colors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.local_car_wash, color: colors.info, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(b.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: b.isOpenNow ? colors.success.withValues(alpha: 0.2) : colors.error.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          b.isOpenNow ? 'Ochiq' : 'Yopiq',
                                          style: TextStyle(
                                            color: b.isOpenNow ? colors.success : colors.error,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(b.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.grey2, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: colors.grey2),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}

/// Retries tile downloads on transient network errors (e.g. dropped
/// connections) and fails silently so a single bad tile doesn't spam errors.
class _RetryingNetworkTileProvider extends NetworkTileProvider {
  _RetryingNetworkTileProvider()
      : super(
          httpClient: RetryClient(
            http.Client(),
            retries: 3,
            whenError: (error, _) => error is http.ClientException,
          ),
          silenceExceptions: true,
        );
}

// ── Data classes ──────────────────────────────────────────────────
class _Cluster {
  final LatLng center;
  final List<BranchModel> branches;
  const _Cluster(this.center, this.branches);
}

// ── Teardrop painter ──────────────────────────────────────────────
class _TeardropPainter extends CustomPainter {
  final Color color;
  _TeardropPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    final path = ui.Path();
    final tipY = h;
    final bodyRadius = w / 2;
    final bodyCenter = Offset(w / 2, bodyRadius);

    // Circle body
    path.addOval(Rect.fromCircle(center: bodyCenter, radius: bodyRadius));
    // Teardrop tip (triangle at bottom)
    path.moveTo(w * 0.3, bodyRadius * 1.6);
    path.lineTo(w / 2, tipY);
    path.lineTo(w * 0.7, bodyRadius * 1.6);
    path.close();

    canvas.drawPath(path, paint);

    // White dot in center
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(bodyCenter, bodyRadius * 0.28, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TeardropPainter old) => old.color != color;
}
