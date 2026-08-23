import 'package:flutter/material.dart';

import '../../models/diet_model.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// A bottom sheet for adding / editing a diet record.
///
/// Collects the food name, quantity, unit, and macronutrient values. The
/// caller passes the target [MealType] and date; the sheet returns a
/// [DietRecordModel] when the user saves.
class MealEditorSheet extends StatefulWidget {
  const MealEditorSheet({
    super.key,
    required this.mealType,
    required this.date,
    this.existing,
  });

  final MealType mealType;
  final DateTime date;
  final DietRecordModel? existing;

  /// Shows the sheet as a modal bottom sheet.
  ///
  /// Returns the created / edited [DietRecordModel], or `null` if the user
  /// cancelled.
  static Future<DietRecordModel?> show(
    BuildContext context, {
    required MealType mealType,
    required DateTime date,
    DietRecordModel? existing,
  }) {
    return GlassBottomSheet.show<DietRecordModel>(
      context,
      options: GlassBottomSheetOptions(
        title: existing != null ? 'Edit ${mealType.name}' : 'Add to ${mealType.name}',
      ),
      child: MealEditorSheet(
        mealType: mealType,
        date: date,
        existing: existing,
      ),
    );
  }

  @override
  State<MealEditorSheet> createState() => _MealEditorSheetState();
}

class _MealEditorSheetState extends State<MealEditorSheet> {
  late final TextEditingController _foodNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _foodNameController = TextEditingController(text: e?.foodName ?? '');
    _quantityController =
        TextEditingController(text: e?.quantity.toStringAsFixed(0) ?? '100');
    _caloriesController =
        TextEditingController(text: e?.calories.toStringAsFixed(0) ?? '');
    _proteinController =
        TextEditingController(text: e?.protein.toStringAsFixed(0) ?? '');
    _carbsController =
        TextEditingController(text: e?.carbs.toStringAsFixed(0) ?? '');
    _fatController =
        TextEditingController(text: e?.fat.toStringAsFixed(0) ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DietRecordModel _buildRecord() {
    final now = DateTime.now().toIso8601String();
    return DietRecordModel(
      id: widget.existing?.id ?? 'diet-${now.hashCode}',
      date: _normalizeDate(widget.date).toIso8601String(),
      mealType: widget.mealType,
      foodName: _foodNameController.text.trim(),
      quantity: double.tryParse(_quantityController.text) ?? 100,
      unit: widget.existing?.unit ?? 'g',
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      notes: _notesController.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
    );
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(
          controller: _foodNameController,
          label: 'Food Name',
          icon: Icons.restaurant,
          autofocus: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _Field(
                controller: _quantityController,
                label: 'Quantity',
                icon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Field(
                controller: TextEditingController(text: 'g'),
                label: 'Unit',
                icon: Icons.straighten,
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Macros
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: _caloriesController,
                label: 'Calories',
                icon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Field(
                controller: _proteinController,
                label: 'Protein (g)',
                icon: Icons.science,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: _carbsController,
                label: 'Carbs (g)',
                icon: Icons.grain,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Field(
                controller: _fatController,
                label: 'Fat (g)',
                icon: Icons.water_drop,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          controller: _notesController,
          label: 'Notes (optional)',
          icon: Icons.note,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassButton(
          label: widget.existing != null ? 'Save Changes' : 'Add Record',
          icon: Icons.check,
          expanded: true,
          onPressed: () {
            if (_foodNameController.text.trim().isEmpty) return;
            Navigator.of(context).pop(_buildRecord());
          },
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autofocus: autofocus,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
