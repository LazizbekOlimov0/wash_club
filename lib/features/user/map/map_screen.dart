import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/i18n/extensions/i18n_extension.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/constants/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  final _repo = BranchesRepository.instance;
  List<BranchModel> _branches = [];
  bool _loading = true;
  bool _locating = false;
  LatLng? _userPosition;

  static const _defaultCenter = LatLng(41.2995, 69.2401); // Toshkent

  @override
  void initState() {
    super.initState();
    _getBranches();
  }

  Future<void> _getLocation() async {
    if (mounted) setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _locating = false);
          _showLocationServiceDialog();
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _locating = false);
            _showSnackBar(context.t.settings.mapPermissionDenied);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _locating = false);
          _showPermissionDeniedForeverDialog();
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        _mapController.move(userLatLng, _mapController.camera.zoom);
        setState(() {
          _userPosition = userLatLng;
          _locating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _locating = false);
        _showSnackBar('${context.t.map.locationError}: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.map.locationServiceOff),
        content: Text(context.t.map.locationServiceOffDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.settings.mapClose),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openLocationSettings();
            },
            child: Text(context.t.settings.mapOpenSettings),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.settings.mapBlocked),
        content: Text(context.t.settings.mapBlockedDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.settings.mapClose),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            },
            child: Text(context.t.settings.mapOpenSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _getBranches() async {
    try {
      _branches = await _repo.getBranches();
      final withCoords = _branches.where((b) => b.latitude != null && b.longitude != null).length;
      debugPrint('[MAP] Jami filial: ${_branches.length}, koordinatali: $withCoords');
      for (final b in _branches) {
        debugPrint('[MAP] ${b.name} — lat: ${b.latitude}, lng: ${b.longitude}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _mapZoom =>
      _userPosition != null ? 13.5 : 11.0;

  LatLng get _mapCenter => _userPosition ?? _defaultCenter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: _mapZoom,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.wash_club.app',
              ),
              // Branch markers
              MarkerLayer(
                markers: _branches
                    .where((b) => b.latitude != null && b.longitude != null)
                    .map((b) => Marker(
                          point: LatLng(b.latitude!, b.longitude!),
                          width: 160,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => _showBranchInfo(context, b, colors),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: colors.primary, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.shadow
                                            .withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    b.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Icon(Icons.location_on,
                                    color: colors.primary, size: 28),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
              // User location marker
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      width: 56,
                      height: 56,
                      child: GestureDetector(
                        onTap: () => _showUserInfo(context, colors),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.info.withValues(alpha: 0.25),
                            border: Border.all(
                                color: colors.info, width: 2.5),
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.info,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // App bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: colors.onSurface, size: 16),
                    ),
                  ),
                  const Spacer(),
                  // My location button
                  GestureDetector(
                    onTap: _getLocation,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.my_location,
                          color: colors.info, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_loading || _locating)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(colors.info),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _locating ? context.t.map.loadingLocation : context.t.map.loadingBranches,
                        style: TextStyle(
                            color: colors.grey2, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showUserInfo(
      BuildContext context, ApparenceKitColors colors) {
    final nearbyCount = _branches
        .where((b) => b.latitude != null && b.longitude != null)
        .length;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.my_location,
                        color: colors.info, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sizning joylashuvingiz',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yaqin atrofda $nearbyCount ta filial mavjud',
                          style: TextStyle(
                              color: colors.grey2, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _branchPlaceholderIcon(ApparenceKitColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.local_car_wash, color: colors.primary, size: 22),
    );
  }

  void _showBranchInfo(
      BuildContext context, BranchModel branch, ApparenceKitColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Image.asset(
                        AppConstants.branchImages[_branches.indexOf(branch) % AppConstants.branchImages.length],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _branchPlaceholderIcon(colors),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          branch.address,
                          style: TextStyle(
                              color: colors.grey2, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);  // close bottom sheet
                    context.pop();       // pop map screen
                    context.go('/booking', extra: {'branchId': branch.id});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(context.t.map.bookButton,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
