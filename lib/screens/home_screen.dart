import 'package:flutter/material.dart';

import 'tabs/feed_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/profile_tab.dart';

/// Uygulamanın ana iskeleti: 4 sekmeli alt gezinme çubuğu.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = <Widget>[HomeTab(), FeedTab(), MapTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack sekmelerin durumunu (kaydırma vb.) korur.
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Kenarlardan ve alttan içeri alınmış, yuvarlak köşeli yüzen alt gezinme çubuğu.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const radius = 28.0;
    return SafeArea(
      child: Padding(
        // Yan boşluklar çubuğu daraltıyor; sekmeler birbirine yaklaşıyor.
        padding: const EdgeInsets.fromLTRB(32, 6, 32, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: NavigationBar(
              height: 68,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              destinations: _destinations,
            ),
          ),
        ),
      ),
    );
  }

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Ana Sayfa',
    ),
    NavigationDestination(
      icon: Icon(Icons.dynamic_feed_outlined),
      selectedIcon: Icon(Icons.dynamic_feed),
      label: 'Akış',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Harita',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];
}
