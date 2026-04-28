import 'package:flutter/material.dart';

class AddCarScreen extends StatefulWidget {
  final VoidCallback? onCarAdded;

  const AddCarScreen({super.key, this.onCarAdded});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  String selectedBodyType = 'Sedan';

  final List<Map<String, String>> bodyTypes = [
    {'label': 'Sedan', 'emoji': '🚗'},
    {'label': 'SUV', 'emoji': '🚙'},
    {'label': 'Minivan', 'emoji': '🚐'},
    {'label': 'Boshqa', 'emoji': '🚗'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          // ── Header (blue section) ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 52,
              left: 24,
              right: 24,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2B5FAD),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: X  Wash Club  ▼  ⋮
                Row(
                  children: [
                    const Icon(Icons.close, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    const Text(
                      'Wash Club',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_vert, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image(
                    image: AssetImage('assets/image/car_img.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Mashinangizni qo'shing",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bron qilish uchun kamida bitta mashina kerak',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // ── Form section ───────────────────────────────────────────
          Expanded(
            child: Container(
              color: const Color(0xFFF2F4F7),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Davlat raqami
                    _label('Davlat raqami', required: true),
                    const SizedBox(height: 8),
                    _textField(hint: '01A123BC'),
                    const SizedBox(height: 6),
                    const Text(
                      'Misol: 01A123BC, 01502GDA, T025004',
                      style: TextStyle(
                        color: Color(0xFF9EA3AE),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Marka + Model
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Marka'),
                              const SizedBox(height: 8),
                              _textField(hint: 'Cobalt'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Model'),
                              const SizedBox(height: 8),
                              _textField(hint: '2024'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Kuzov turi
                    _label('Kuzov turi'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.6,
                      children: bodyTypes.map((type) {
                        final isSelected =
                            selectedBodyType == type['label'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedBodyType = type['label']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDEE8F8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2B5FAD)
                                    : Colors.transparent,
                                width: 1.8,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(type['emoji']!,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  type['label']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? const Color(0xFF2B5FAD)
                                        : const Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom button ──────────────────────────────────────────
          Container(
            color: const Color(0xFFF2F4F7),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  widget.onCarAdded?.call();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8FCA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Davom etish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        if (required)
          const Text(' *',
              style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Widget _textField({required String hint}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFBCC0CC),
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color(0xFF2B5FAD), width: 1.5),
        ),
      ),
    );
  }
}