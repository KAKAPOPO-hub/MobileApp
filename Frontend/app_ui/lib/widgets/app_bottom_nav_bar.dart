import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class NavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final Widget page; 

  const NavItem({required this.icon, this.selectedIcon, required this.page});
}

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.maxWidth = 380,
    this.barColor = Colors.white,
    this.selectedColor,
    this.unselectedColor = Colors.grey,
  }) : assert(items.length > 0, 'At least one navigation item is required');

  final List<NavItem> items;
  final int initialIndex;

  final double maxWidth;

  final Color barColor;
  final Color? selectedColor;
  final Color unselectedColor;

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        widget.selectedColor ?? Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BottomBar(
        theme: const BottomBarThemeData(
          barDecoration: BoxDecoration(color: Colors.white),
        ),
        layout: BottomBarLayout(
          width: MediaQuery.sizeOf(context).width - 32,
          maxWidth: widget.maxWidth,
          offset: 12,
          alignment: Alignment.bottomCenter,
          fit: StackFit.loose,
        ),

        body: BottomBarBodyPadding(
          child: IndexedStack(
            index: _currentIndex,
            children: [for (final item in widget.items) item.page],
          ),
        ),

        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.barColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 48, 48, 48).withValues(alpha: 0.12),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: BottomBarItems(
            children: [
              for (int i = 0; i < widget.items.length; i++)
                BottomBarItem(
                  icon: Icon(
                    _currentIndex == i
                        ? (widget.items[i].selectedIcon ?? widget.items[i].icon)
                        : widget.items[i].icon,
                    color: _currentIndex == i
                        ? selectedColor
                        : widget.unselectedColor,
                  ),
                  onTap: () => setState(() => _currentIndex = i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
