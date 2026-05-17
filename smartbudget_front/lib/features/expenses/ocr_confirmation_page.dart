import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/transactions_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/category_utils.dart';
import '../../data/models/transaction.dart';
import '../../services/ocr_service.dart';

class OcrConfirmationPage extends ConsumerStatefulWidget {
  final OcrResult ocrResult;
  final String source;

  const OcrConfirmationPage({
    super.key,
    required this.ocrResult,
    required this.source,
  });

  @override
  ConsumerState<OcrConfirmationPage> createState() => _OcrConfirmationPageState();
}

class _OcrConfirmationPageState extends ConsumerState<OcrConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.ocrResult.merchant ?? '');
    _amountController = TextEditingController(
      text: widget.ocrResult.amount != null ? widget.ocrResult.amount!.toStringAsFixed(2) : '',
    );
    _selectedDate = widget.ocrResult.date ?? DateTime.now();
    _dateController = TextEditingController(
      text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
    );
    
    // Attempt to guess category based on merchant
    _guessCategory(widget.ocrResult.merchant ?? '');
  }

  void _guessCategory(String merchant) {
    final m = merchant.toLowerCase();
    if (m.contains('restaurante') || m.contains('cafe') || m.contains('pizza') || m.contains('food')) {
      _selectedCategory = 'Comida';
    } else if (m.contains('uber') || m.contains('taxi') || m.contains('bus') || m.contains('grifo') || m.contains('gas')) {
      _selectedCategory = 'Transporte';
    } else if (m.contains('farmacia') || m.contains('botica') || m.contains('salud')) {
      _selectedCategory = 'Salud';
    } else if (m.contains('market') || m.contains('supermercado') || m.contains('tienda')) {
      _selectedCategory = 'Compras';
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirmExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una categoría')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final merchant = _merchantController.text.trim();
      final desc = _descriptionController.text.trim();
      final info = CategoryUtils.getCategoryInfo(_selectedCategory!);

      final title = desc.isNotEmpty ? desc : merchant.isNotEmpty ? merchant : _selectedCategory!;

      final transaction = TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory!,
        icon: info.icon,
        categoryColor: info.color,
        categoryBackground: info.background,
        isIncome: false,
      );

      ref.read(transactionsProvider.notifier).addTransaction(transaction);
      
      if (context.mounted) {
        // Return true to indicate success
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Confirmar Gasto OCR',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.source == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.document_scanner_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Revisa los datos extraídos del documento. Puedes editarlos si es necesario.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormLabel(label: 'Comercio / Entidad'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _merchantController,
                      decoration: _inputDecoration().copyWith(hintText: 'Ej: Supermercado'),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _FormLabel(label: 'Monto (S/)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: _inputDecoration().copyWith(
                        prefixText: 'S/ ',
                        prefixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Monto inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _FormLabel(label: 'Fecha'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _inputDecoration().copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _FormLabel(label: 'Categoría'),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    
                    _FormLabel(label: 'Descripción (Opcional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration().copyWith(hintText: 'Ej: Compra mensual'),
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _confirmExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                        label: const Text(
                          'Confirmar y Guardar',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      hint: const Text('Selecciona una categoría'),
      isExpanded: true,
      decoration: _inputDecoration(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      items: CategoryUtils.categories.map((info) {
        return DropdownMenuItem<String>(
          value: info.name,
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: info.background, shape: BoxShape.circle),
                child: Icon(info.icon, color: info.color, size: 14),
              ),
              const SizedBox(width: 10),
              Text(info.name, style: AppTextStyles.body),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: (v) => v == null ? 'Requerido' : null,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.background,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.danger)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.danger, width: 2)),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3),
    );
  }
}
