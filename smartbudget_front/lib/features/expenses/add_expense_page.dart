import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/providers/budget_provider.dart';
import '../../core/providers/privacy_settings_provider.dart';
import '../../core/providers/transactions_provider.dart';
import '../../core/theme/adaptive_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/category_utils.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/budget_overflow_dialog.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/finance_background.dart';
import '../../data/models/transaction.dart';
import '../../services/ocr_service.dart';
import 'ocr_confirmation_page.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────
class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  bool _isScanning = false;
  final _ocrService = OcrService();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  // ── Top snackbar-style toast ────────────────────────────────────────────────
  void _showTopToast(String message) {
    showAppToast(context, message: message);
  }

  Future<void> _scanDocument(String source) async {
    setState(() => _isScanning = true);
    try {
      Uint8List? bytes;
      String? fileName;

      if (source == 'camera') {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          bytes = await pickedFile.readAsBytes();
          fileName = pickedFile.name;
        }
      } else if (source == 'gallery') {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          bytes = await pickedFile.readAsBytes();
          fileName = pickedFile.name;
        }
      } else if (source == 'pdf') {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        );
        if (result != null) {
          final file = result.files.single;
          fileName = file.name;
          if (file.bytes != null) {
            bytes = file.bytes;
          } else if (file.path != null) {
            bytes = await XFile(file.path!).readAsBytes();
          }
        }
      }

      if (bytes != null && fileName != null) {
        _showTopToast('Analizando documento...');

        final ocrResult = await _ocrService.processImage(bytes, fileName);

        if (mounted) {
          setState(() => _isScanning = false);
          final result = await Navigator.of(context).push(
            PageRouteBuilder<bool>(
              transitionDuration: const Duration(milliseconds: 260),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder: (_, _, _) =>
                  OcrConfirmationPage(ocrResult: ocrResult, source: source),
              transitionsBuilder: (_, animation, _, child) {
                final offsetAnimation =
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic))
                        .animate(animation);

                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          );
          if (result == true) {
            _showTopToast('Gasto guardado exitosamente');
          }
        }
      } else {
        setState(() => _isScanning = false);
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        showAppToast(
          context,
          message: 'Error al procesar el documento: $e',
          icon: Icons.error_outline_rounded,
          accentColor: AppColors.danger,
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final desc = _descriptionController.text.trim();
      final budget = ref
          .read(budgetProvider)
          .maybeWhen(data: (budget) => budget, orElse: () => null);

      if (budget != null && amount > budget.saldoDisponible) {
        final shouldContinue = await showBudgetOverflowDialog(
          context: context,
          expenseAmount: amount,
          availableBalance: budget.saldoDisponible,
        );

        if (!shouldContinue || !mounted) return;
      }

      setState(() => _isSubmitting = true);

      await Future.delayed(const Duration(milliseconds: 200));

      await ref
          .read(transactionsProvider.notifier)
          .addTransaction(
            category: _selectedCategory!,
            amount: amount,
            description: desc,
            date: DateTime.now(),
            source: 'manual',
          );

      if (!mounted) return;

      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _isSubmitting = false;
      });

      _showTopToast('Gasto registrado exitosamente');
    }
  }

  Widget _buildScanOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: context.financeSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.document_scanner_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escaneo Automático',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Escanea una boleta o factura para registrar automáticamente tus gastos',
                        style: TextStyle(
                          color: context.financeText.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _ScanOptionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Cámara',
                    onTap: () => _scanDocument('camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScanOptionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galería',
                    onTap: () => _scanDocument('gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScanOptionButton(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Archivo',
                    onTap: () => _scanDocument('pdf'),
                  ),
                ),
              ],
            ),
          ),
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.financeBackground,
      body: FinanceBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Agregar Gasto', style: AppTextStyles.heading2),
                          const SizedBox(height: 4),
                          Text(
                            'Elige una opción para registrar tu gasto',
                            style: AppTextStyles.body.copyWith(
                              color: context.financeTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scan options card
                    _buildScanOptions(),

                    // Card form
                    Container(
                      decoration: BoxDecoration(
                        color: context.financeSurface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card header – green accent bar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Registro Manual',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Ingresa los detalles del gasto',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Form body
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Category
                                  _FormLabel(label: 'Categoría'),
                                  const SizedBox(height: 8),
                                  _buildCategoryDropdown(),
                                  const SizedBox(height: 20),

                                  // Amount
                                  _FormLabel(label: 'Monto (S/)'),
                                  const SizedBox(height: 8),
                                  _buildAmountField(),
                                  const SizedBox(height: 20),

                                  // Description
                                  _FormLabel(label: 'Descripción (opcional)'),
                                  const SizedBox(height: 8),
                                  _buildDescriptionField(),
                                  const SizedBox(height: 28),

                                  // Submit button
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: _isSubmitting || _isScanning
                                          ? null
                                          : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        disabledBackgroundColor:
                                            AppColors.primaryLight,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.add_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                      label: Text(
                                        'Agregar Gasto Manual',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
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

  // ── Dropdown ─────────────────────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      hint: const Text('Selecciona una categoría'),
      isExpanded: true,
      decoration: _inputDecoration(),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primary,
      ),
      dropdownColor: context.financeSurface,
      borderRadius: BorderRadius.circular(16),
      items: CategoryUtils.categories.map((info) {
        return DropdownMenuItem<String>(
          value: info.name,
          child: Row(
            children: [
              CategoryIcon(info: info, size: 32),
              const SizedBox(width: 12),
              Text(info.name, style: AppTextStyles.body),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) => CategoryUtils.categories.map((info) {
        return Row(
          children: [
            CategoryIcon(info: info, size: 28),
            const SizedBox(width: 10),
            Text(info.name, style: AppTextStyles.body),
          ],
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: (value) => value == null ? 'Selecciona una categoría' : null,
    );
  }

  // ── Amount field ─────────────────────────────────────────────────────────────
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.financeText,
      ),
      decoration: _inputDecoration().copyWith(
        hintText: '50.00',
        prefixText: 'S/  ',
        prefixStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa un monto';
        if (double.tryParse(value) == null) return 'Monto inválido';
        if ((double.tryParse(value) ?? 0) <= 0) {
          return 'El monto debe ser mayor a 0';
        }
        return null;
      },
    );
  }

  // ── Description field ────────────────────────────────────────────────────────
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: _inputDecoration().copyWith(
        hintText: 'Ej: Almuerzo en restaurante',
      ),
    );
  }

  // ── Shared InputDecoration ───────────────────────────────────────────────────
  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: context.financeInputFill,
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
}

// ─── Scan Option Button ──────────────────────────────────────────────────────
class _ScanOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: context.financeBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.financeText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form label helper ───────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.financeTextSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Public transaction tile widget (reused in dashboard & analysis) ─────────
class TransactionTile extends ConsumerWidget {
  final TransactionItem transaction;
  final bool showDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideAmounts = ref.watch(privacySettingsProvider).hideAmounts;
    final info = CategoryUtils.getCategoryInfo(transaction.category);
    final time =
        '${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${transaction.date.day} ${_monthAbbr(transaction.date.month)}';

    return Container(
      decoration: BoxDecoration(
        color: context.financeSurface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CategoryIcon(info: info, size: 46, iconSize: 22),
        title: Text(
          transaction.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.financeText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Text(
                transaction.category,
                style: TextStyle(
                  fontSize: 12,
                  color: context.financeTextSecondary,
                ),
              ),
              const _Dot(),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: context.financeTextSecondary,
                ),
              ),
              const _Dot(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: context.financeTextSecondary,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                privacyAmount(
                  transaction.amount,
                  hidden: hideAmounts,
                  negative: true,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                ),
              ),
            ),
            if (showDelete) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  tooltip: 'Eliminar gasto',
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final confirmed = await showAppConfirmDialog(
                      context: context,
                      title: 'Eliminar gasto',
                      message:
                          '¿Seguro que deseas eliminar "${transaction.title}"? El monto se devolverá a tu presupuesto disponible.',
                      confirmLabel: 'Eliminar',
                      icon: Icons.delete_outline_rounded,
                      accentColor: AppColors.danger,
                    );

                    if (!confirmed || !context.mounted) return;

                    await ref
                        .read(transactionsProvider.notifier)
                        .removeTransaction(transaction.id);

                    if (!context.mounted) return;
                    showAppToast(
                      context,
                      message: 'Gasto eliminado',
                      icon: Icons.delete_outline_rounded,
                      accentColor: AppColors.danger,
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: context.financeTextMuted,
                    size: 19,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return months[month - 1];
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '•',
        style: TextStyle(color: context.financeTextMuted, fontSize: 11),
      ),
    );
  }
}
