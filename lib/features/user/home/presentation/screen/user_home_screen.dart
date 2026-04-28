import 'package:flutter/material.dart';

import '../../../booking/booking_screen.dart';
import '../../../orders/orders_screen.dart';
import 'add_car/add_car_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final List<bool> _expanded = [false, false, false];

  // Foydalanuvchining mashinasi bor yoki yo'qligini simulatsiya qiladi
  // Haqiqiy loyihada bu backenddan keladi
  bool _hasCar = false;

  void _onBookOrAdd(BuildContext context) {
    if (_hasCar) {
      // Mashinasi bor → Bron qilish tabiga o'tish
      setState(() => _selectedIndex = 1);
    } else {
      // Mashinasi yo'q → Mashina qo'shish ekraniga yo'naltirish
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddCarScreen(
            onCarAdded: () {
              setState(() => _hasCar = true);
            },
          ),
        ),
      );
    }
  }

  final List<Map<String, String>> _branches = [
    {'name': 'Underground Car Wash - Oybek', 'address': 'Shakhrisabz street', 'bays': '10'},
    {'name': 'Mega Planet', 'address': 'Yakkasaray', 'bays': '6'},
    {'name': 'HT mall', 'address': 'yangi shahar', 'bays': ''},
    {'name': 'Drive CarWash Mega Planet', 'address': 'Ahmad Donish 2B', 'bays': ''},
    {'name': 'Yupiter', 'address': '', 'bays': ''},
    {'name': 'Yevro Car Wash - Tashkent city', 'address': 'Amir Temur', 'bays': ''},
  ];

  final List<String> _faqTitles = [
    '1. Добавить машину',
    '2. Бронь или подписка',
    '3. Приезжайте и мойте',
  ];
  final List<String> _faqIcons = ['🚗', '📅', '✅'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      bottomNavigationBar: _buildBottomNav(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0 - Главная
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildBookButton(),
                const SizedBox(height: 16),
                _buildTariffPlans(),
                const SizedBox(height: 16),
                _buildBranchesSection(),
                const SizedBox(height: 16),
                _buildHowItWorks(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // 1 - Бронь
          const BookingScreen(),
          // 2 - Заказы
          const OrdersScreen(),
          // 3 - Профиль (placeholder)
          const Center(child: Text('Профиль')),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF2B3A6B), Color(0xFF3B2D6B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добро пожаловать',
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lazizbek Olimov',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '+998991048024',
                      style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🚿', style: TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x44000000),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Статус подписки',
                        style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 13),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Нет подписки',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Оформите подписку — экономьте!',
                        style: TextStyle(color: Color(0x88FFFFFF), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text('💳', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _onBookOrAdd(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2B5FAD),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Забронировать',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTariffPlans() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2340),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Тарифные планы',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Экономьте каждый месяц!',
              style: TextStyle(color: Color(0xFFFFD166), fontSize: 13),
            ),
            const SizedBox(height: 16),

            // 3 months
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3560),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _tariffContent(
                icon: '🪃',
                title: '3 месяца',
                price: '933 000 UZS',
                total: 'Итого: 2 800 000 UZS',
              ),
            ),
            const SizedBox(height: 16),

            // 6 months (best price)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3560),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4A017),
                      width: 1.5,
                    ),
                  ),
                  child: _tariffContent(
                    icon: '👑',
                    title: '6 месяцев',
                    price: '799 000 UZS',
                    total: 'Итого: 4 794 000 UZS',
                  ),
                ),
                Positioned(
                  top: -12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Лучшая цена',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tariffContent({
    required String icon,
    required String title,
    required String price,
    required String total,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$icon  $title',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '∞ Безлимитные мойки',
          style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ' / мес',
                style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          total,
          style: const TextStyle(color: Color(0xFF4DD9AC), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBranchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filiallar header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Филиалы',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${_branches.length} шт',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2B5FAD),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal cards (first 2)
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 2,
            itemBuilder: (context, i) {
              final b = _branches[i];
              return Container(
                width: 175,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on_outlined,
                          color: Color(0xFF2B5FAD), size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      b['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (b['address']!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        b['address']!,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9EA3AE)),
                      ),
                    ],
                    const Spacer(),
                    if (b['bays']!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFB800), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${b['bays']} bay',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Na karte title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('🗺', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'На карте',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Vertical list
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _branches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final b = _branches[i];
            return Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: Color(0xFF2B5FAD), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        if (b['address']!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            b['address']!,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF9EA3AE)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (i > 0)
                    const Icon(Icons.near_me_outlined,
                        color: Color(0xFF9EA3AE), size: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Как это работает?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_faqTitles.length, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Text(_faqIcons[i],
                    style: const TextStyle(fontSize: 24)),
                title: Text(
                  _faqTitles[i],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                trailing: Icon(
                  _expanded[i]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF9EA3AE),
                ),
                onTap: () =>
                    setState(() => _expanded[i] = !_expanded[i]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'label': 'Главная', 'icon': Icons.home_outlined},
      {'label': 'Бронь', 'icon': Icons.calendar_today_outlined},
      {'label': 'Заказы', 'icon': Icons.receipt_long_outlined},
      {'label': 'Профиль', 'icon': Icons.person_outline},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: selected
                          ? const Color(0xFF2B5FAD)
                          : const Color(0xFF9EA3AE),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected
                            ? const Color(0xFF2B5FAD)
                            : const Color(0xFF9EA3AE),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2B5FAD),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}