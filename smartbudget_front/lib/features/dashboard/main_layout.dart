import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import '../analysis/analysis_page.dart';
import '../expenses/add_expense_page.dart';
import '../goals/goals_page.dart';
import '../profile/profile_page.dart';
import 'dashboard_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static const String routePath = '/home';

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _analysisHistoryFocusRequest = 0;

  void _openProfileSettings() {
    setState(() {
      _currentIndex = 4;
    });
  }

  void _openAnalysisHistory() {
    setState(() {
      _analysisHistoryFocusRequest++;
      _currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(
            onOpenSettings: _openProfileSettings,
            onViewAllTransactions: _openAnalysisHistory,
          ),
          const AddExpensePage(),
          const GoalsPage(),
          AnalysisPage(historyFocusRequest: _analysisHistoryFocusRequest),
          const ProfilePage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Accion de la varita magica (ej. IA)
          showAppToast(
            context,
            message: '¡Asistente IA muy pronto!',
            icon: Icons.auto_awesome,
          );
        },
        child: const Icon(Icons.auto_awesome),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.28)
                  : AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
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
