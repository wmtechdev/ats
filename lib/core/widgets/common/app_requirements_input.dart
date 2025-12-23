import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppRequirementsInput extends StatefulWidget {
  final List<String> requirements;
  final void Function(List<String>)? onChanged;
  final String? Function(List<String>)? validator;

  const AppRequirementsInput({
    super.key,
    required this.requirements,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppRequirementsInput> createState() => _AppRequirementsInputState();
}

class _AppRequirementsInputState extends State<AppRequirementsInput> {
  late List<String> _requirements;
  final TextEditingController _textController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _requirements = List.from(widget.requirements);
    _textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(AppRequirementsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requirements.length != _requirements.length ||
        !widget.requirements.every((req) => _requirements.contains(req))) {
      _requirements = List.from(widget.requirements);
    }
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide suffix icon
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addRequirement(String requirement) {
    final trimmed = requirement.trim();
    if (trimmed.isNotEmpty && !_requirements.contains(trimmed)) {
      setState(() {
        _requirements.add(trimmed);
        _textController.clear();
        _errorText = null;
        widget.onChanged?.call(_requirements);
        _validate();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
      widget.onChanged?.call(_requirements);
      _validate();
    });
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_requirements);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips display
        if (_requirements.isNotEmpty) ...[
          Wrap(
            spacing: AppResponsive.screenWidth(context) * 0.02,
            runSpacing: AppResponsive.screenHeight(context) * 0.01,
            children: _requirements.asMap().entries.map((entry) {
              return Chip(
                label: Text(
                  entry.value,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppTextStyles.bodyText(context).fontSize! * 0.9,
                  ),
                ),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                deleteIcon: Icon(
                  Iconsax.close_circle,
                  size: AppResponsive.iconSize(context, factor: 0.8),
                  color: AppColors.error,
                ),
                onDeleted: () => _removeRequirement(entry.key),
                padding: AppSpacing.all(context, factor: 0.2),
              );
            }).toList(),
          ),
          AppSpacing.vertical(context, 0.02),
        ],
        // Input field
        TextField(
          controller: _textController,
          style: AppTextStyles.bodyText(context),
          decoration: InputDecoration(
            labelText: 'Add Requirement',
            hintText: 'Type and press Enter',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: AppColors.lightGrey,
            labelStyle: AppTextStyles.hintText(context),
            hintStyle: AppTextStyles.hintText(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 5),
              ),
              borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 5),
              ),
              borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 5),
              ),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            prefixIcon: Icon(
              Iconsax.tick_circle,
              size: AppResponsive.iconSize(context),
              color: AppColors.primary,
            ),
            suffixIcon: _textController.text.trim().isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Iconsax.add,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.primary,
                    ),
                    onPressed: () => _addRequirement(_textController.text),
                  )
                : null,
            contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
            errorText: _errorText,
          ),
          onSubmitted: _addRequirement,
        ),
      ],
    );
  }
}

