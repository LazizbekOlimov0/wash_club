import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/extensions/theme_extension.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../config/router/router.dart';
import 'widgets/branch_info_card.dart';

/// Filiallarni `GoogleMap` widget'i bilan ko'rsatuvchi ekran.
///
/// Asosiy Xarita ekrani. Eski [MapScreen] (flutter_map) hali ham kod bazasida
/// saqlanmoqda — Google Maps'da muammo chiqsa tezda orqaga qaytarish uchun.
class GoogleMapScreen extends StatefulWidget {
  final String? focusBranchId;

  const GoogleMapScreen({super.key, this.focusBranchId});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen>
    with TickerProviderStateMixin {
  final _repo = BranchesRepository.instance;
  GoogleMapController? _mapController;

  List<BranchModel> _branches = [];
  bool _loading = true;
  bool _locating = false;
  bool _routing = false;
  LatLng? _userPosition;
  BranchModel? _selectedBranch;
  Polyline? _routePolyline;
  String _selectedFilter = 'all';
  bool _showList = false;
  bool _listPanelVisible = false;

  late AnimationController _listCtrl;
  late Animation<Offset> _listSlideAnim;

  static const _defaultCenter = LatLng(41.2995, 69.2401); // Toshkent

  @override
  void initState() {
    super.initState();
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
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _getBranches() async {
    try {
      _branches = await _repo.getBranches();
      if (mounted && widget.focusBranchId != null) {
        final b = _branches.where((x) => x.id == widget.focusBranchId).firstOrNull;
        if (b != null && b.latitude != null && b.longitude != null) {
          _selectedBranch = b;
          _moveCamera(LatLng(b.latitude!, b.longitude!), 15.0);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      if (mounted) {
        setState(() => _userPosition = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {
      // Joylashuvni jimgina aniqlab bo'lmadi.
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      if (mounted) {
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        _moveCamera(userLatLng, 14.0);
        setState(() {
          _userPosition = userLatLng;
          _locating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _moveCamera(LatLng target, double zoom) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
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

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.t.map.locationServiceOff),
        content: Text(context.t.map.locationServiceOffDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t.settings.mapClose)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
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
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text(context.t.settings.mapOpenSettings),
          ),
        ],
      ),
    );
  }

  void _selectBranch(BranchModel b) {
    setState(() => _selectedBranch = b);
    if (b.latitude != null && b.longitude != null) {
      _moveCamera(LatLng(b.latitude!, b.longitude!), 15.0);
    }
  }

  // ── Route (OSRM) → Polyline ────────────────────────────────────
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
            setState(() => _routePolyline = _buildRoutePolyline(points));
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

  Polyline _buildRoutePolyline(List<LatLng> points) {
    final colors = context.colors;
    return Polyline(
      polylineId: const PolylineId('osrm_route'),
      points: points,
      width: 5,
      color: colors.info,
    );
  }

  void _fallbackStraightLine(LatLng user, LatLng branch) {
    final points = [user, branch];
    setState(() => _routePolyline = _buildRoutePolyline(points));
    _fitRouteBounds(points);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.map.routeFailed)),
      );
    }
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;
    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      minLat = minLat == null ? p.latitude : (p.latitude < minLat ? p.latitude : minLat);
      maxLat = maxLat == null ? p.latitude : (p.latitude > maxLat ? p.latitude : maxLat);
      minLng = minLng == null ? p.longitude : (p.longitude < minLng ? p.longitude : minLng);
      maxLng = maxLng == null ? p.longitude : (p.longitude > maxLng ? p.longitude : maxLng);
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat!, minLng!),
          northeast: LatLng(maxLat!, maxLng!),
        ),
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final markers = buildMarkersFromBranches(
      _filteredBranches,
      selectedBranchId: _selectedBranch?.id,
      onTap: _selectBranch,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userPosition ?? _defaultCenter,
              zoom: _userPosition != null ? 13.5 : 11.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: markers.toSet(),
            polylines: _routePolyline != null ? {_routePolyline!} : const {},
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) {
              if (_showList) {
                _setListVisible(false);
              } else if (_selectedBranch != null) {
                setState(() => _selectedBranch = null);
              }
            },
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
                          decoration: BoxDecoration(
                            color: colors.mapBadge,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: colors.onBackground, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        t.map.title,
                        style: TextStyle(color: colors.onCenterBG, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 14,
            bottom: 110,
            child: GestureDetector(
              onTap: _goToMyLocation,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.mapBadge,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.my_location, color: colors.onBackground, size: 20),
              ),
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_showList ? Icons.map : Icons.list, color: colors.onBackground, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _showList ? t.map.showMap : t.map.showList,
                        style: TextStyle(color: colors.onBackground, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Branch list panel
          if (_listPanelVisible) _buildBranchListPanel(colors, _listSlideAnim),

          // Tanlangan filial paneli (BranchInfoCard — map_screen bilan umumiy)
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
                      key: ValueKey(_selectedBranch!.id),
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
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(colors.info),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _locating ? t.map.loadingLocation : t.map.loadingBranches,
                      style: TextStyle(color: colors.grey2, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Filter chip ────────────────────────────────────────────────
  Widget _buildFilterChip(String key, String label, ApparenceKitColors colors) {
    final selected = _selectedFilter == key;
    final fgColor = selected ? Colors.white : colors.onBackground;
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
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
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
    final withCoords = _filteredBranches
        .where((b) => b.latitude != null && b.longitude != null)
        .toList();
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
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: colors.grey2, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.t.home.branches,
                    style: TextStyle(color: colors.onBackground, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: withCoords.length,
                    itemBuilder: (_, i) {
                      final b = withCoords[i];
                      return GestureDetector(
                        onTap: () {
                          _setListVisible(false);
                          _moveCamera(LatLng(b.latitude!, b.longitude!), 15.0);
                        },
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colors.info.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                          child: Text(
                                            b.name,
                                            style: TextStyle(color: colors.onBackground, fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: b.isOpenNow
                                                ? colors.success.withValues(alpha: 0.2)
                                                : colors.error.withValues(alpha: 0.2),
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
                                    Text(
                                      b.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: colors.grey2, fontSize: 12),
                                    ),
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

/// [BranchModel] ro'yxatini `GoogleMap` uchun [Marker]lar ro'yxatiga aylantiradi.
///
/// Koordinatasi bo'lmagan filiallar o'tkazib yuboriladi. `selectedBranchId`
/// tanlangan filial markerini boshqa rangda ko'rsatish uchun ishlatiladi.
List<Marker> buildMarkersFromBranches(
  List<BranchModel> branches, {
  String? selectedBranchId,
  void Function(BranchModel branch)? onTap,
}) {
  final branchIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  final selectedIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  return branches
      .where((b) => b.latitude != null && b.longitude != null)
      .map((b) {
        final selected = b.id == selectedBranchId;
        return Marker(
          markerId: MarkerId(b.id),
          position: LatLng(b.latitude!, b.longitude!),
          icon: selected ? selectedIcon : branchIcon,
          onTap: onTap == null ? null : () => onTap(b),
        );
      })
      .toList();
}
