// =============================================================================
// PHỎNG VẤN KIẾN THỨC - home_screen.dart (Shell sau đăng nhập)
// =============================================================================
//
//   Q1. _currentIndex và _screens — tại sao không dùng Navigator + routes?
//   A1. Hai tab (Sản phẩm, Giỏ hàng) cùng cấp, không stack — dùng index + list widget đơn giản
//       hơn Navigator. Navigator phù hợp khi có stack (chi tiết, form). Ở đây chỉ đổi body và
//       nav highlight.
//
//   Q2. isWide (width >= 768 hoặc web >= 600) điều khiển gì? Bottom nav vs sidebar?
//   A2. isWide: true thì hiện sidebar trái (240px) + ẩn bottom nav; false thì ẩn sidebar +
//       hiện BottomNavigationBar. Responsive: mobile bottom nav, tablet/web sidebar.
//
//   Q3. ProductListScreen và CartScreen được tạo const trong list — có bị build lại khi đổi tab không?
//   A3. _screens build một lần (const). Khi _currentIndex đổi chỉ _screens[_currentIndex] được
//       hiển thị; cả hai màn vẫn nằm trong cây (Offstage hoặc không build phần kia tùy impl).
//       Thực tế Row/Column chỉ render child đang hiển thị; list không rebuild toàn bộ.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: StatefulWidget, _currentIndex, _screens = [ProductListScreen, CartScreen].
//   build: Row(sidebar nếu isWide, Expanded(Column(AppBar + body, CartIconWidget))), bottomNav nếu !isWide.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Được pushReplacement từ AuthScreen. Là shell chính: tab Sản phẩm (list)
//   và tab Giỏ hàng; CartIconWidget trên AppBar chuyển sang tab Giỏ hàng khi tap.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/cart_icon_widget.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';

/// HomeScreen - Màn hình chính sau đăng nhập (2 tab: Sản phẩm, Giỏ hàng)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProductListScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 768 || (kIsWeb && width >= 600);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar trên màn hình rộng (web/tablet)
          if (isWide)
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(1, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              size: 28,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ShopCart',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _NavItem(
                      icon: Icons.store_outlined,
                      selectedIcon: Icons.store_rounded,
                      label: 'Sản phẩm',
                      selected: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.shopping_cart_outlined,
                      selectedIcon: Icons.shopping_cart_rounded,
                      label: 'Giỏ hàng',
                      selected: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
          // Nội dung chính
          Expanded(
            child: Column(
              children: [
                // AppBar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          if (!isWide)
                            Text(
                              '🛍️ ShopCart',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          if (isWide)
                            Text(
                              _currentIndex == 0 ? 'Sản phẩm' : 'Giỏ hàng',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          const Spacer(),
                          CartIconWidget(
                            onTap: () {
                              setState(() => _currentIndex = 1);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
      // Bottom nav cho mobile
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store_rounded),
                  label: 'Sản phẩm',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart_rounded),
                  label: 'Giỏ hàng',
                ),
              ],
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
