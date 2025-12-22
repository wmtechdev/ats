import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';

class AppAuthFormContent extends StatelessWidget {
  final bool isLoginSelected;
  final List<Widget> formFields;
  final Widget actionButton;

  const AppAuthFormContent({
    super.key,
    required this.isLoginSelected,
    required this.formFields,
    required this.actionButton,
  });

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
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey<bool>(isLoginSelected),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...formFields,
          AppSpacing.vertical(context, 0.03),
          actionButton,
        ],
      ),
    );
  }
}

