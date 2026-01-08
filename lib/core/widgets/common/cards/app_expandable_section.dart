import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

class AppExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool hasError;
  final bool initiallyExpanded;

  const AppExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.hasError = false,
    this.initiallyExpanded = false,
  });

  @override
  State<AppExpandableSection> createState() => _AppExpandableSectionState();
}

class _AppExpandableSectionState extends State<AppExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(
          color: widget.hasError
              ? AppColors.error
              : AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppResponsive.radius(context, factor: 1.5)),
            ),
            child: Padding(
              padding: AppSpacing.all(context, factor: 0.8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyText(
                            context,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (widget.hasError) ...[
                          AppSpacing.horizontal(context, 0.02),
                          Icon(
                            Iconsax.danger,
                            color: AppColors.error,
                            size: AppResponsive.iconSize(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                    size: AppResponsive.iconSize(context),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.all(context, factor: 0.8).left,
                right: AppSpacing.all(context, factor: 0.8).right,
                bottom: AppSpacing.all(context, factor: 0.8).bottom,
              ),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
