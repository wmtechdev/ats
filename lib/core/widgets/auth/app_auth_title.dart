import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppAuthTitle extends StatelessWidget {
  final String title;

  const AppAuthTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        title,
        key: ValueKey<String>(title),
        textAlign: TextAlign.center,
        style: AppTextStyles.heading(
          context,
        ).copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
