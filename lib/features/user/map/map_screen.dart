import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/i18n/extensions/i18n_extension.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../config/router/router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  final _repo = BranchesRepository.instance;
  List<BranchModel> _branches = [];
  bool _loading = true;
  bool _locating = false;
  LatLng? _userPosition;
  bool _showList = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

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
    _getBranches();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getBranches() async {
    try {
      _branches = await _repo.getBranches();
    } finally {
      if (mounted) setState(() => _loading = false);
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

  double get _mapZoom => _userPosition != null ? 13.5 : 11.0;
  LatLng get _mapCenter => _userPosition ?? _defaultCenter;

  // ── Simple grid-based clustering ────────────────────────────────
  List<_Cluster> _buildClusters() {
    if (_branches.isEmpty) return [];

    final withCoords = _branches
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
              maxZoom: 18,
              onTap: (_, real) => _showList ? setState(() => _showList = false) : null,
            ),
            children: [
              // Dark tile layer — CartoDB dark matter
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                userAgentPackageName: 'com.wash_club.app',
                maxZoom: 19,
              ),
              // Branch markers (teardrop style)
              MarkerLayer(
                markers: clusters.map((cluster) {
                  final isCluster = cluster.branches.length > 1;
                  return Marker(
                    point: cluster.center,
                    width: isCluster ? 48 : 36,
                    height: isCluster ? 48 : 42,
                    child: GestureDetector(
                      onTap: () => _onClusterTap(cluster, colors),
                      child: isCluster
                          ? _buildClusterWidget(cluster.branches.length, colors)
                          : _buildTeardropMarker(colors),
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

          // Header: back + title
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: _btnDecoration(colors),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: colors.onSurface, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(t.map.title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
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
                _ctrlBtn(Icons.my_location, _goToMyLocation, colors, iconColor: colors.info),
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
                onTap: () => setState(() => _showList = !_showList),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
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
          if (_showList) _buildBranchListPanel(colors),

          // Loading
          if (_loading || _locating)
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

  // ── Cluster tap → zoom in ──────────────────────────────────────
  void _onClusterTap(_Cluster cluster, ApparenceKitColors colors) {
    if (cluster.branches.length == 1) {
      final b = cluster.branches.first;
      _showBranchInfo(b, colors);
    } else {
      // Zoom into cluster
      final bounds = LatLngBounds.fromPoints(cluster.branches.map((b) => LatLng(b.latitude!, b.longitude!)).toList());
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)));
    }
  }

  // ── Markers ─────────────────────────────────────────────────────
  Widget _buildTeardropMarker(ApparenceKitColors colors) {
    return CustomPaint(
      painter: _TeardropPainter(colors.info),
      size: const Size(36, 42),
      child: const SizedBox.expand(),
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
    color: const Color(0xFF1C1C1E),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
  );

  Widget _ctrlBtn(IconData icon, VoidCallback onTap, ApparenceKitColors colors, {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: _btnDecoration(colors),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }

  // ── Branch list panel ───────────────────────────────────────────
  Widget _buildBranchListPanel(ApparenceKitColors colors) {
    final withCoords = _branches.where((b) => b.latitude != null && b.longitude != null).toList();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: GestureDetector(
        onTap: () {}, // block taps through
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
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
                      onTap: () { _showList = false; _mapController.move(LatLng(b.latitude!, b.longitude!), 15.0); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
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
                                  Text(b.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
    );
  }

  // ── Branch info bottom sheet ────────────────────────────────────
  void _showBranchInfo(BranchModel branch, ApparenceKitColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.grey2, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text(branch.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(branch.address, style: TextStyle(color: colors.grey2, fontSize: 13)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(UserRoutePath.booking, extra: {'branchId': branch.id});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.info,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(context.t.home.bookButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
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
