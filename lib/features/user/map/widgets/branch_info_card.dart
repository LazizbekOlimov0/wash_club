import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/extensions/theme_extension.dart';
import 'package:wash_club/shared/services/supabase_service.dart';

/// Filial ma'lumot kartasi (tanlangan filial paneli).
///
/// [MapScreen] va GoogleMap'ga asoslangan ekran uchun umumiy widget —
/// filial kartasini ikki joyda qayta yozmaslik uchun shu yerga chiqarilgan.
class BranchInfoCard extends StatelessWidget {
  const BranchInfoCard({
    super.key,
    required this.branch,
    required this.onClose,
    required this.onRoute,
    required this.onBook,
    this.userLat,
    this.userLng,
  });

  final BranchModel branch;
  final double? userLat;
  final double? userLng;
  final VoidCallback onClose;
  final VoidCallback onRoute;
  final VoidCallback onBook;

  bool get _hasValidUserPos =>
      userLat != null &&
      userLng != null &&
      !(userLat == 0.0 && userLng == 0.0);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final hasPos = branch.latitude != null && branch.longitude != null;

    String? distanceTimeText;
    if (_hasValidUserPos && hasPos) {
      final user = LatLng(userLat!, userLng!);
      final branchLatLng = LatLng(branch.latitude!, branch.longitude!);
      final km = _distanceKm(user, branchLatLng);
      final min = _estimateMinutes(km);
      distanceTimeText =
          '${_distanceText(user, branchLatLng)} • $min ${t.map.minuteShort}';
    }

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.mapBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Katta surat + yopish tugmasi
                Stack(
                  children: [
                    _buildBranchImage(context),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildCloseButton(context),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameRatingCall(context),
                      const SizedBox(height: 14),
                      _buildAddress(context),
                      const SizedBox(height: 12),
                      _buildOpenHours(context),
                      const SizedBox(height: 14),
                      _buildDistance(context, distanceTimeText),
                      const SizedBox(height: 18),
                      _buildAmenities(context),
                      const SizedBox(height: 14),
                      _buildServices(context),
                      const SizedBox(height: 18),
                      _buildButtons(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchImage(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: branch.imageUrl != null && branch.imageUrl!.isNotEmpty
          ? Image.network(
              branch.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _branchImagePlaceholder(colors),
            )
          : _branchImagePlaceholder(colors),
    );
  }

  Widget _branchImagePlaceholder(ApparenceKitColors colors) {
    return Container(
      color: colors.info.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.local_car_wash_rounded, color: colors.info, size: 48),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildNameRatingCall(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      branch.name,
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.verified, color: colors.info, size: 16),
                ],
              ),
              if (branch.rating != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      branch.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildCallButton(context),
      ],
    );
  }

  Widget _buildCallButton(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    return GestureDetector(
      onTap: () => _callBranch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.info.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call, color: colors.info, size: 18),
            const SizedBox(width: 6),
            Text(
              t.map.call,
              style: TextStyle(
                color: colors.info,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callBranch(BuildContext context) async {
    final phone = branch.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.map.noPhone)),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Telefon ilovasi ochilmadi.
    }
  }

  Widget _buildAmenities(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAmenityCard(
            Icons.star,
            'Premium',
            branch.isPremium ? Colors.amber : colors.grey3,
            colors,
          ),
          _buildAmenityCard(Icons.wifi, 'Wi-Fi', colors.grey3, colors),
          _buildAmenityCard(Icons.coffee, 'Coffee', colors.grey3, colors),
        ],
      ),
    );
  }

  Widget _buildAmenityCard(
      IconData icon, String label, Color iconColor, ApparenceKitColors colors) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.mapSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.grey2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    final colors = context.colors;
    if (branch.services.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: branch.services.take(6).map((s) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: colors.mapSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  s.name,
                  style: TextStyle(color: colors.grey2, fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddress(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(Icons.place_outlined, color: colors.grey2, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            branch.address,
            style: TextStyle(color: colors.grey2, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenHours(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: branch.isOpenNow
                ? colors.success.withValues(alpha: 0.2)
                : colors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: branch.isOpenNow ? colors.success : colors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                branch.isOpenNow ? t.map.openNow : t.map.closedNow,
                style: TextStyle(
                  color: branch.isOpenNow ? colors.success : colors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          branch.hoursLabel,
          style: TextStyle(color: colors.grey2, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDistance(BuildContext context, String? distanceTimeText) {
    final t = context.t;
    final colors = context.colors;
    final hasPos = branch.latitude != null && branch.longitude != null;
    if (!hasPos) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: colors.info, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            distanceTimeText ?? t.map.distanceUnknown,
            style: TextStyle(
              color: colors.onBackground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: Text(t.map.route),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onBackground,
              side: BorderSide(color: colors.grey2.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(t.map.bookButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  static double _distanceKm(LatLng a, LatLng b) =>
      const Distance().as(LengthUnit.Kilometer, a, b);

  static int _estimateMinutes(double km) {
    const avgSpeedKmh = 32.0; // shahar ichi o'rtacha tezlik
    return (km / avgSpeedKmh * 60).round().clamp(1, 999);
  }

  static String _distanceText(LatLng a, LatLng b) {
    final km = _distanceKm(a, b);
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
}
