import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'dashboard_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static const String routePath = '/home';

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const Center(child: Text('Agregar', style: AppTextStyles.heading2)),
    const Center(child: Text('Metas', style: AppTextStyles.heading2)),
    const Center(child: Text('Análisis', style: AppTextStyles.heading2)),
    const Center(child: Text('Perfil', style: AppTextStyles.heading2)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción de la varita mágica (ej. IA)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Asistente IA muy pronto!')),
          );
        },
        child: const Icon(Icons.auto_awesome),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                elevation: 0,
                backgroundColor: Colors.transparent,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_filled),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline),
                    activeIcon: Icon(Icons.add_circle),
                    label: 'Agregar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.track_changes_outlined),
                    activeIcon: Icon(Icons.track_changes),
                    label: 'Metas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart),
                    label: 'Análisis',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
