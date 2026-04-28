import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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

  /// 🔥 KEY GLOBAL BIEN DEFINIDA
  final GlobalKey<GoalsPageState> _goalsKey = GlobalKey<GoalsPageState>();

  late final List<Widget> _pages = [
    const DashboardPage(),
    const AddExpensePage(),
    GoalsPage(key: _goalsKey), // 👈 AQUÍ
    const AnalysisPage(),
    const ProfilePage(),
  ];

  void _handleFAB() {
    if (_currentIndex == 2) {
      _goalsKey.currentState?.showIASuggestion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("IA disponible pronto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: _handleFAB,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Análisis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}