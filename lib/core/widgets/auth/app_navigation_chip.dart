import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppNavigationChip extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final bool isFirstSelected;
  final VoidCallback onFirstTap;
  final VoidCallback onSecondTap;

  const AppNavigationChip({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.isFirstSelected,
    required this.onFirstTap,
    required this.onSecondTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChip(
              context: context,
              label: firstLabel,
              isSelected: isFirstSelected,
              onTap: onFirstTap,
            ),
            AppSpacing.horizontal(context, 0.01),
            _buildChip(
              context: context,
              label: secondLabel,
              isSelected: !isFirstSelected,
              onTap: onSecondTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.04, v: 0.005),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyText(context).copyWith(
            color: isSelected ? AppColors.white : AppColors.grey,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
