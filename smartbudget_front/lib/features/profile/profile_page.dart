import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/budget_provider.dart';
import '../../core/theme/adaptive_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_toast.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _budgetController;
  bool _notificationsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _goalRemindersEnabled = false;
  bool _biometricLockEnabled = false;
  bool _hideAmountsEnabled = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.go(LoginPage.routePath);
    }
  }

  void _showTopToast(
    String message, {
    IconData icon = Icons.check_rounded,
    Color accentColor = AppColors.primary,
  }) {
    showAppToast(
      context,
      message: message,
      icon: icon,
      accentColor: accentColor,
    );
  }

  void _saveBudget() {
    final newBudget = double.tryParse(_budgetController.text) ?? 0.0;
    if (newBudget <= 0) {
      _showTopToast(
        'Ingresa un presupuesto mayor a 0',
        icon: Icons.error_outline_rounded,
        accentColor: AppColors.danger,
      );
      return;
    }

    ref.read(budgetProvider.notifier).createBudget(newBudget);
    _showTopToast('Presupuesto actualizado');
  }

  Future<void> _showExtraBudgetSheet() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              setSheetState(() => isSubmitting = true);

              final amount = double.parse(amountController.text.trim());
              final description = descriptionController.text.trim();

              await ref
                  .read(budgetProvider.notifier)
                  .addAdditionalIncome(amount, description);

              if (!context.mounted) return;
              Navigator.of(context).pop();
              _showTopToast(
                'Presupuesto extra agregado',
                icon: Icons.add_card_rounded,
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _SettingsSheet(
                title: 'Presupuesto extra',
                icon: Icons.add_card_rounded,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Agrega un ingreso adicional a tu presupuesto disponible del mes.',
                          style: AppTextStyles.body.copyWith(
                            color: context.financeTextSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Monto extra (S/)',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _settingsInputDecoration(
                            hintText: 'Ej: 250',
                            prefixText: 'S/  ',
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            if (amount == null || amount <= 0) {
                              return 'Ingresa un monto mayor a 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Descripción', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _settingsInputDecoration(
                            hintText: 'Ej: Bono, venta o ingreso adicional',
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Describe el ingreso extra';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primaryLight,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                  ),
                            label: const Text(
                              'Agregar extra',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      amountController.dispose();
      descriptionController.dispose();
    });
  }

  InputDecoration _settingsInputDecoration({
    required String hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: context.financeInputFill,
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: AppTextStyles.body.copyWith(color: context.financeTextMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
    );
  }

  void _showNotificationsSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _SettingsSheet(
              title: 'Notificaciones',
              icon: Icons.notifications_none,
              children: [
                _SettingsSwitchTile(
                  title: 'Activar notificaciones',
                  subtitle: 'Recibe avisos importantes de SmartBudget+',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    setSheetState(() {});
                  },
                ),
                _SettingsSwitchTile(
                  title: 'Alertas de presupuesto',
                  subtitle: 'Avísame cuando esté cerca del límite mensual',
                  value: _budgetAlertsEnabled,
                  enabled: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _budgetAlertsEnabled = value);
                    setSheetState(() {});
                  },
                ),
                _SettingsSwitchTile(
                  title: 'Recordatorios de metas',
                  subtitle: 'Recibe recordatorios para abonar a tus metas',
                  value: _goalRemindersEnabled,
                  enabled: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _goalRemindersEnabled = value);
                    setSheetState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _SettingsSheet(
              title: 'Privacidad y seguridad',
              icon: Icons.shield_outlined,
              children: [
                _SettingsSwitchTile(
                  title: 'Ocultar montos',
                  subtitle: 'Reduce la visibilidad de importes en público',
                  value: _hideAmountsEnabled,
                  onChanged: (value) {
                    setState(() => _hideAmountsEnabled = value);
                    setSheetState(() {});
                  },
                ),
                _SettingsSwitchTile(
                  title: 'Bloqueo biométrico',
                  subtitle: 'Requerir validación al volver a la app',
                  value: _biometricLockEnabled,
                  onChanged: (value) {
                    setState(() => _biometricLockEnabled = value);
                    setSheetState(() {});
                  },
                ),
                _SettingsActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión segura',
                  subtitle: 'Elimina el token guardado en este dispositivo',
                  color: AppColors.danger,
                  onTap: () {
                    Navigator.of(context).pop();
                    _logout();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGeneralSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SettingsSheet(
          title: 'Configuración',
          icon: Icons.settings_outlined,
          children: [
            _SettingsActionTile(
              icon: Icons.currency_exchange_rounded,
              title: 'Moneda',
              subtitle: 'Soles peruanos (S/)',
              onTap: () => _showTopToast(
                'La moneda actual es S/',
                icon: Icons.currency_exchange_rounded,
              ),
            ),
            _SettingsActionTile(
              icon: Icons.refresh_rounded,
              title: 'Actualizar datos',
              subtitle: 'Sincroniza presupuesto y sesión',
              onTap: () {
                ref.read(budgetProvider.notifier).refresh();
                ref.invalidate(authControllerProvider);
                Navigator.of(context).pop();
                _showTopToast(
                  'Datos actualizados',
                  icon: Icons.refresh_rounded,
                );
              },
            ),
            _SettingsActionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Guardar presupuesto',
              subtitle: 'Aplica el monto ingresado arriba',
              onTap: () {
                Navigator.of(context).pop();
                _saveBudget();
              },
            ),
            _SettingsActionTile(
              icon: Icons.add_card_rounded,
              title: 'Presupuesto extra',
              subtitle: 'Suma un ingreso adicional al saldo disponible',
              onTap: () {
                Navigator.of(context).pop();
                _showExtraBudgetSheet();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHelpSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SettingsSheet(
          title: 'Ayuda y soporte',
          icon: Icons.help_outline,
          children: [
            _SettingsActionTile(
              icon: Icons.info_outline_rounded,
              title: 'Guía rápida',
              subtitle: 'Registra ingresos, gastos y metas desde las pestañas',
              onTap: () => _showSupportDialog(
                title: 'Guía rápida',
                message:
                    'Configura tu presupuesto mensual, registra tus gastos y usa metas para separar dinero de tus objetivos.',
              ),
            ),
            _SettingsActionTile(
              icon: Icons.bug_report_outlined,
              title: 'Reportar problema',
              subtitle: 'Revisa el estado del backend y la sesión',
              onTap: () => _showSupportDialog(
                title: 'Soporte técnico',
                message:
                    'Si algo no carga, prueba Actualizar datos. Si persiste, verifica que Docker siga activo y que el backend responda en /docs.',
              ),
            ),
            _SettingsActionTile(
              icon: Icons.verified_outlined,
              title: 'Versión',
              subtitle: 'SmartBudget+ 1.0.0',
              onTap: () => _showTopToast(
                'SmartBudget+ 1.0.0',
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSupportDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.financeSurface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(title, style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: context.financeTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    final budgetState = ref.watch(budgetProvider);
    budgetState.whenOrNull(
      data: (summary) {
        if (summary != null && _budgetController.text.isEmpty) {
          _budgetController.text = summary.montoBase.toStringAsFixed(0);
        }
      },
    );

    return Scaffold(
      backgroundColor: context.financeBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(
                    user?.nombre ?? 'Usuario',
                    user?.email ?? 'usuario@email.com',
                  ),
                  const SizedBox(height: 20),

                  _buildBudgetSection(),
                  const SizedBox(height: 20),

                  _buildSettingsSection(),
                  const SizedBox(height: 30),

                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: context.financeSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppTextStyles.small.copyWith(
                  color: context.financeTextSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.financeSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Presupuesto Mensual',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ingresa el dinero total que tienes disponible este mes',
            style: AppTextStyles.small.copyWith(
              color: context.financeTextSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Monto Total (S/)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (_) => _saveBudget(),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              hintText: 'Ej: 2000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              label: const Text(
                'Guardar presupuesto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  'Presupuesto configurado: ',
                  style: AppTextStyles.small.copyWith(
                    color: context.financeText,
                    fontSize: 13,
                  ),
                ),
                ref
                    .watch(budgetProvider)
                    .maybeWhen(
                      data: (summary) => Text(
                        summary != null
                            ? 'S/ ${summary.montoBase.toStringAsFixed(2)}'
                            : 'No configurado',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      orElse: () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.financeSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            label: 'Notificaciones',
            onTap: _showNotificationsSettings,
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            label: 'Privacidad y seguridad',
            onTap: _showPrivacySettings,
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.settings_outlined,
            label: 'Configuración',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.add_card_rounded,
            label: 'Presupuesto extra',
            onTap: _showExtraBudgetSheet,
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.help_outline,
            label: 'Ayuda y soporte',
            onTap: _showHelpSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? _settingsActionForIcon(icon),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.financeTextMuted,
            size: 22,
          ),
        ],
      ),
    );
  }

  VoidCallback _settingsActionForIcon(IconData icon) {
    if (icon == Icons.notifications_none) return _showNotificationsSettings;
    if (icon == Icons.shield_outlined) return _showPrivacySettings;
    if (icon == Icons.settings_outlined) return _showGeneralSettings;
    if (icon == Icons.add_card_rounded) return _showExtraBudgetSheet;
    if (icon == Icons.help_outline) return _showHelpSettings;
    return () {};
  }
}

class _SettingsSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSheet({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.financeSurface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: context.financeTextSecondary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    color: enabled
                        ? AppColors.textPrimary
                        : context.financeTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.small.copyWith(
                    color: enabled
                        ? AppColors.textSecondary
                        : context.financeTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled ? value : false,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.small.copyWith(
                      color: context.financeTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.financeTextMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
