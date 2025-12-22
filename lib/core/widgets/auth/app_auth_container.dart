import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';

class AppAuthContainer extends StatelessWidget {
  final Widget child;

  const AppAuthContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = _getMaxWidth(context);

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }

  double _getMaxWidth(BuildContext context) {
    if (AppResponsive.isDesktop(context)) return 500.0;
    if (AppResponsive.isTablet(context)) return 450.0;
    return double.infinity;
  }
}

