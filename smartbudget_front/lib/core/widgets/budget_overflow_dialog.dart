import 'package:flutter/material.dart';

import '../theme/adaptive_colors.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

Future<bool> showBudgetOverflowDialog({
  required BuildContext context,
  required double expenseAmount,
  required double availableBalance,
}) async {
  final exceededAmount = expenseAmount - availableBalance;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
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
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Presupuesto superado',
                style: AppTextStyles.heading3.copyWith(
                  color: context.financeText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este gasto haria que superes tu saldo disponible del mes.',
                style: AppTextStyles.body.copyWith(
                  color: context.financeTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.financeSurfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.financeBorder),
                ),
                child: Column(
                  children: [
                    _BudgetWarningRow(
                      label: 'Disponible actual',
                      value: 'S/ ${availableBalance.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _BudgetWarningRow(
                      label: 'Gasto ingresado',
                      value: 'S/ ${expenseAmount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _BudgetWarningRow(
                      label: 'Exceso estimado',
                      value: 'S/ ${exceededAmount.toStringAsFixed(2)}',
                      isDanger: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: context.financeTextSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}

class _BudgetWarningRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDanger;

  const _BudgetWarningRow({
    required this.label,
    required this.value,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.small),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: isDanger ? AppColors.danger : context.financeText,
          ),
        ),
      ],
    );
  }
}

