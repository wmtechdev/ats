import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/common/forms/app_required_label.dart';

/// Widget for tag input where users can add multiple tags by pressing Enter
class AppTagInput extends StatefulWidget {
  final List<String> tags;
  final void Function(List<String> tags) onTagsChanged;
  final String? labelText;
  final String? hintText;
  final bool showLabelAbove;

  const AppTagInput({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.labelText,
    this.hintText,
    this.showLabelAbove = false,
  });

  @override
  State<AppTagInput> createState() => _AppTagInputState();
}

class _AppTagInputState extends State<AppTagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !widget.tags.contains(trimmedTag)) {
      final updatedTags = [...widget.tags, trimmedTag];
      widget.onTagsChanged(updatedTags);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    final isRequired = widget.labelText?.endsWith('(*)') ?? false;
    final cleanLabelText = isRequired
        ? widget.labelText!.substring(0, widget.labelText!.length - 3)
        : widget.labelText;

    final textField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: AppTextStyles.bodyText(context),
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Type and press Enter to add',
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTextStyles.hintText(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      ),
      onSubmitted: (value) {
        _addTag(value);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabelAbove && cleanLabelText != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.vertical(context, 0.01).height!,
            ),
            child: isRequired
                ? AppRequiredLabel(text: cleanLabelText)
                : Text(
                    cleanLabelText,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
          ),
        // Tags display
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: AppSpacing.horizontal(context, 0.01).width!,
            runSpacing: AppSpacing.vertical(context, 0.01).height!,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: Icon(
                  Iconsax.close_circle,
                  size: AppResponsive.iconSize(context) * 0.8,
                  color: AppColors.error,
                ),
                onDeleted: () => _removeTag(tag),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: AppTextStyles.bodyText(
                  context,
                ).copyWith(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 3),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
              );
            }).toList(),
          ),
        if (widget.tags.isNotEmpty)
          SizedBox(height: AppSpacing.vertical(context, 0.01).height),
        textField,
      ],
    );
  }
}
