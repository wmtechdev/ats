import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppSearchCreateBar extends StatelessWidget {
  final String searchHint;
  final String createButtonText;
  final IconData createButtonIcon;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onCreatePressed;
  final TextEditingController? searchController; // Optional controller for search field

  const AppSearchCreateBar({
    super.key,
    required this.searchHint,
    required this.createButtonText,
    required this.createButtonIcon,
    this.onSearchChanged,
    this.onCreatePressed,
    this.searchController, // Add controller parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.padding(context),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              key: const ValueKey('search-field'), // Stable key to preserve state
              controller: searchController, // Use provided controller
              hintText: searchHint,
              prefixIcon: Iconsax.search_normal,
              onChanged: onSearchChanged,
            ),
          ),
          if (onCreatePressed != null) ...[
            AppSpacing.horizontal(context, 0.02),
            AppButton(
              text: createButtonText,
              icon: createButtonIcon,
              onPressed: onCreatePressed,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}
