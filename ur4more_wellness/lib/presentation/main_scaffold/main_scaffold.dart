import 'package:flutter/material.dart';
import '../home_dashboard/home_dashboard.dart';
import '../body_fitness_screen/body_fitness_screen.dart';
import '../../features/mind/presentation/mind_coach_screen.dart';
import '../spiritual_growth_screen/spiritual_growth_screen.dart';
import '../rewards_marketplace_screen/rewards_marketplace_screen.dart';
import '../../widgets/brand_glyph_text.dart';
import '../../widgets/demo_mode_banner.dart';
import '../../widgets/gateway_error_banner.dart';
import '../../services/gateway_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  GatewayError? _lastError;

  final _pages = const [
    HomeDashboard(),
    BodyFitnessScreen(),
    MindCoachScreen(),
    SpiritualGrowthScreen(),
    RewardsMarketplaceScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check for errors periodically
    _checkForErrors();
  }

  void _checkForErrors() {
    setState(() {
      _lastError = GatewayService.lastError;
    });
    // Check again after a delay
    Future.delayed(const Duration(seconds: 2), _checkForErrors);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const DemoModeBanner(),
          if (_lastError != null)
            GatewayErrorBanner(
              error: _lastError!,
              onDismiss: () {
                setState(() {
                  _lastError = null;
                });
              },
            ),
          Expanded(
            child: IndexedStack(index: _index, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow, // Labels on
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color:
                  _index == 0
                      ? theme.colorScheme.primary
                      : const Color(0xFF94A3B8),
            ),
            selectedIcon: const BrandGlyphText(size: 22),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.fitness_center_outlined,
              color:
                  _index == 1
                      ? theme.colorScheme.primary
                      : const Color(0xFF94A3B8),
            ),
            selectedIcon: Icon(
              Icons.fitness_center,
              color: theme.colorScheme.primary,
            ),
            label: 'Body',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.psychology_alt_outlined,
              color:
                  _index == 2
                      ? theme.colorScheme.primary
                      : const Color(0xFF94A3B8),
            ),
            selectedIcon: Icon(
              Icons.psychology_alt,
              color: theme.colorScheme.primary,
            ),
            label: 'Mind',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.auto_awesome_outlined,
              color:
                  _index == 3
                      ? theme.colorScheme.primary
                      : const Color(0xFF94A3B8),
            ),
            selectedIcon: Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
            ),
            label: 'Spirit',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.card_giftcard_outlined,
              color:
                  _index == 4
                      ? theme.colorScheme.primary
                      : const Color(0xFF94A3B8),
            ),
            selectedIcon: Icon(
              Icons.card_giftcard,
              color: theme.colorScheme.primary,
            ),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }
}
