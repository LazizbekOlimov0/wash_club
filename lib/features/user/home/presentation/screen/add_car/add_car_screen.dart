import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/i18n/translations.g.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../shared/services/client_session.dart';

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
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _plateController.text.trim().length >= 5;

  Future<void> _save() async {
    if (!_isValid || _saving) return;

    // Keyboard yopish
    FocusScope.of(context).unfocus();

    setState(() { _saving = true; _error = null; });

    try {
      final car = SavedCar(
        plate:    _plateController.text.trim().toUpperCase(),
        brand:    '',
        model:    _modelController.text.trim(),
        bodyType: 'Sedan',
        color:    _colorController.text.trim(),
      );

      // 1) SharedPrefs'ga saqlaymiz
      await ClientSession.instance.addCar(car);

      // 2) Callbackni pop'dan oldin chaqiramiz
      widget.onCarAdded?.call();

      // 3) Pop
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _saving = false; });
    }
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
        systemOverlayStyle:
            Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: colors.onSurface, size: 16),
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
              _buildHeroHeader(colors),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_error!,
                              style: TextStyle(
                                  color: colors.error, fontSize: 13)),
                        ),
                      _sectionLabel(t.addCar.plate, required: true, colors: colors),
                      const SizedBox(height: 10),
                      _plateField(colors),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          t.addCar.plateExample,
                          style: TextStyle(
                            color: colors.grey2.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _sectionLabel(t.addCar.carModel, colors: colors),
                      const SizedBox(height: 10),
                      _buildField(
                          controller: _modelController,
                          hint: t.addCar.carModelHint,
                          colors: colors),
                      const SizedBox(height: 22),
                      _sectionLabel(t.addCar.color, colors: colors),
                      const SizedBox(height: 10),
                      _buildField(
                          controller: _colorController,
                          hint: t.addCar.colorHint,
                          icon: Icons.color_lens_outlined,
                          colors: colors),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(ApparenceKitColors colors) {
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
          colors: [
            colors.primary.withValues(alpha: 0.25),
            colors.background,
          ],
        ),
      ),
      child: Row(
        children: [
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
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: colors.primary, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        t.addCar.secureSaving,
                        style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
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

  Widget _sectionLabel(String text,
      {bool required = false, required ApparenceKitColors colors}) {
    return Row(
      children: [
        Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.grey2,
                letterSpacing: 0.5)),
        if (required)
          Text(' *', style: TextStyle(color: colors.error, fontSize: 13)),
      ],
    );
  }

  Widget _plateField(ApparenceKitColors colors) {
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
            child: Text('UZ',
                style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1)),
          ),
          Expanded(
            child: TextField(
              controller: _plateController,
              style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '01A 123 BC',
                hintStyle: TextStyle(
                    color: colors.disabledContent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required ApparenceKitColors colors,
    IconData? icon,
  }) {
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
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: colors.disabledContent, fontSize: 15),
          prefixIcon: icon != null
              ? Icon(icon, color: colors.grey2, size: 18)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBottomButton(ApparenceKitColors colors) {
    final isActive = _isValid && !_saving;
    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(
        20, 12, 20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isActive ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.disabled,
            foregroundColor: colors.onPrimary,
            disabledForegroundColor: colors.disabledContent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: _saving
              ? SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                  ),
                )
              : Text(
                  t.addCar.continueButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: colors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
