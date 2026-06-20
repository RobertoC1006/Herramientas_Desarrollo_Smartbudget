import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/providers/transactions_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/category_utils.dart';
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
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _TopToast(message: message),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      entry.remove();
    });
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
            MaterialPageRoute(
              builder: (_) => OcrConfirmationPage(ocrResult: ocrResult, source: source),
            )
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el documento: $e')),
        );
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      await Future.delayed(const Duration(milliseconds: 200));

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final desc = _descriptionController.text.trim();

      ref.read(transactionsProvider.notifier).addTransaction(
        category: _selectedCategory!,
        amount: amount,
        description: desc,
        date: DateTime.now(),
        source: 'manual',
      );

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
        color: AppColors.surface,
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
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
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                            color: AppColors.textSecondary,
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
                      color: AppColors.surface,
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
                                    color: Colors.white.withValues(alpha: 0.2),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    onPressed: _isSubmitting || _isScanning ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      disabledBackgroundColor:
                                          AppColors.primaryLight,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
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
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      items: CategoryUtils.categories.map((info) {
        return DropdownMenuItem<String>(
          value: info.name,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: info.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icon, color: info.color, size: 16),
              ),
              const SizedBox(width: 12),
              Text(info.name, style: AppTextStyles.body),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) => CategoryUtils.categories.map((info) {
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: info.background,
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.color, size: 14),
            ),
            const SizedBox(width: 10),
            Text(info.name, style: AppTextStyles.body),
          ],
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: (value) =>
          value == null ? 'Selecciona una categoría' : null,
    );
  }

  // ── Amount field ─────────────────────────────────────────────────────────────
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
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
        if ((double.tryParse(value) ?? 0) <= 0) return 'El monto debe ser mayor a 0';
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
      fillColor: AppColors.background,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
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
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Animated top toast overlay ─────────────────────────────────────────────
class _TopToast extends StatefulWidget {
  final String message;
  const _TopToast({required this.message});

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Start dismiss after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
    final info = CategoryUtils.getCategoryInfo(transaction.category);
    final time =
        '${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${transaction.date.day} ${_monthAbbr(transaction.date.month)}';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: info.background,
            shape: BoxShape.circle,
          ),
          child: Icon(info.icon, color: info.color, size: 22),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Text(
                transaction.category,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const _Dot(),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const _Dot(),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-S/ ${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE5484D),
              ),
            ),
            if (showDelete) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ref
                      .read(transactionsProvider.notifier)
                      .removeTransaction(transaction.id);
                },
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFB0B8C1),
                  size: 20,
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
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return months[month - 1];
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '•',
        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
    );
  }
}
