import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/privacy_settings_provider.dart';
import '../../core/theme/adaptive_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/finance_background.dart';
import '../analysis/analysis_page.dart';
import '../expenses/add_expense_page.dart';
import '../goals/goals_page.dart';
import '../profile/profile_page.dart';
import 'dashboard_page.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  static const String routePath = '/home';

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with WidgetsBindingObserver {
  static const _pageTransitionDuration = Duration(milliseconds: 260);
  static const _pageTransitionCurve = Curves.easeOutCubic;

  late final PageController _pageController;
  int _currentIndex = 0;
  int _analysisHistoryFocusRequest = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(privacySettingsProvider.notifier).lockIfEnabled();
    }
  }

  void _goToTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: _pageTransitionDuration,
      curve: _pageTransitionCurve,
    );
  }

  void _openProfileSettings() {
    _goToTab(4);
  }

  void _openAnalysisHistory() {
    setState(() {
      _analysisHistoryFocusRequest++;
    });
    _goToTab(3);
  }

  @override
  Widget build(BuildContext context) {
    final privacySettings = ref.watch(privacySettingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            allowImplicitScrolling: false,
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
          if (privacySettings.isLocked) const _PrivacyLockOverlay(),
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
                  _goToTab(index);
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

class _PrivacyLockOverlay extends ConsumerWidget {
  const _PrivacyLockOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: FinanceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xl),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: context.financeSurface,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: context.financeBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.34)
                          : AppColors.shadow,
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'App bloqueada',
                      style: AppTextStyles.heading2.copyWith(
                        color: context.financeText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tus datos financieros están protegidos. Desbloquea para continuar.',
                      style: AppTextStyles.body.copyWith(
                        color: context.financeTextSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(privacySettingsProvider.notifier).unlock();
                        },
                        icon: const Icon(
                          Icons.fingerprint_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Desbloquear',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
