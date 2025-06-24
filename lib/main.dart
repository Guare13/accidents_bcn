import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/historic_screen.dart';
import 'screens/xifres_screen.dart';
import 'package:provider/provider.dart';
import 'providers/year_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => YearProvider(),
      child: const AccidentsApp(),
    ),
  );
}

class AccidentsApp extends StatelessWidget {
  const AccidentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Accidents BCN',
  theme: ThemeData(
    scaffoldBackgroundColor: const Color(0xFFEAF4FB), // Blau clar com a fons general
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)), // Blau base
    useMaterial3: true,
  ),
  home: const MainNavigation(),
  debugShowCheckedModeBanner: false,
);
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MapScreen(),
    HistoricScreen(),
    XifresScreen(),
  ];

  final List<String> _titles = ['Inici', 'Mapa', 'Històric', 'Xifres'];
  final List<IconData> _icons = [Icons.home, Icons.map, Icons.timeline, Icons.bar_chart];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_selectedIndex]),
            centerTitle: true,
          ),
          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(_titles.length, (i) {
                    return NavigationRailDestination(
                      icon: Icon(_icons[i]),
                      label: Text(_titles[i]),
                    );
                  }),
                ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  destinations: List.generate(_titles.length, (i) {
                    return NavigationDestination(
                      icon: Icon(_icons[i]),
                      label: _titles[i],
                    );
                  }),
                ),
        );
      },
    );
  }
}