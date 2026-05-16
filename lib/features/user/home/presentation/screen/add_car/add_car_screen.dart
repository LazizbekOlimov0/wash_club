import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/i18n/translations.g.dart';
import '../../../../../../core/theme/colors.dart';

extension ThemeX on BuildContext {
  ApparenceKitColors get colors =>
      Theme.of(this).extension<ApparenceKitColors>()!;
}

class AddCarScreen extends StatefulWidget {
  final VoidCallback? onCarAdded;

  const AddCarScreen({super.key, this.onCarAdded});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen>
    with SingleTickerProviderStateMixin {
  String selectedBodyType = 'Sedan';

  late AnimationController _animController;

  late Animation<double> _fadeAnim;

  late Animation<Offset> _slideAnim;

  final TextEditingController _plateController = TextEditingController();

  final TextEditingController _brandController = TextEditingController();

  final TextEditingController _modelController = TextEditingController();

  final List<Map<String, dynamic>> bodyTypes = [
    {'label': 'Sedan', 'icon': Icons.directions_car_rounded},
    {'label': 'SUV', 'icon': Icons.directions_car_filled_rounded},
    {'label': 'Minivan', 'icon': Icons.airport_shuttle_rounded},
    {'label': 'Others', 'icon': Icons.commute_rounded},
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();

    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.onSurface,
              size: 16,
            ),
          ),
        ),
        title: Text(
          t.addCar.title,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              _buildHeroHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel(t.addCar.plate, required: true),

                      const SizedBox(height: 10),

                      _plateField(),

                      const SizedBox(height: 6),

                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Masalan: 01A123BC · 01502GDA · T025004',
                          style: TextStyle(
                            color: colors.grey2.withValues(alpha: 0.7),
                            fontSize: 12,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Marka'),

                                const SizedBox(height: 10),

                                _buildTextField(
                                  controller: _brandController,
                                  hint: 'Chevrolet',
                                  icon: Icons.directions_car_outlined,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Model'),

                                const SizedBox(height: 10),

                                _buildTextField(
                                  controller: _modelController,
                                  hint: 'Cobalt 2024',
                                  icon: Icons.calendar_today_outlined,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      _sectionLabel(t.addCar.bodyType),

                      const SizedBox(height: 14),

                      _bodyTypeGrid(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 72,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withValues(alpha: 0.25), colors.background],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/image/car_img.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.directions_car_rounded,
                  color: colors.primary,
                  size: 40,
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.addCar.title,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.infoSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: colors.primary,
                        size: 13,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        'Xavfsiz saqlash',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {bool required = false}) {
    final colors = context.colors;

    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.grey2,
            letterSpacing: 0.5,
          ),
        ),

        if (required)
          Text(' *', style: TextStyle(color: colors.error, fontSize: 13)),
      ],
    );
  }

  Widget _plateField() {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              'UZ',
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),

          Expanded(
            child: TextField(
              controller: _plateController,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: '01A 123 BC',
                hintStyle: TextStyle(
                  color: colors.disabledContent,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: colors.grey2,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.disabledContent, fontSize: 15),
          prefixIcon: Icon(icon, color: colors.grey2, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _bodyTypeGrid() {
    final colors = context.colors;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: bodyTypes.map((type) {
        final isSelected = selectedBodyType == type['label'];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBodyType = type['label'];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? colors.infoSurface : colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? colors.primary : colors.divider,
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryWithOpacity(0.15)
                        : colors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    type['icon'] as IconData,
                    size: 18,
                    color: isSelected ? colors.primary : colors.grey2,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  type['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colors.primary : colors.grey2,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButton() {
    final colors = context.colors;

    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            widget.onCarAdded?.call();

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            shadowColor: colors.primaryWithOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.addCar.continueButton,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: colors.onPrimary,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
