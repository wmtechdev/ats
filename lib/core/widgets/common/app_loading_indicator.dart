import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ats/core/utils/app_lotties/app_lotties.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

class AppLoadingIndicator extends StatelessWidget {
  final bool isPrimary;
  final double? size;

  const AppLoadingIndicator({
    super.key,
    this.isPrimary = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? AppResponsive.iconSize(context, factor: 2);
    
    return Center(
      child: SizedBox(
        width: loadingSize,
        height: loadingSize,
        child: Lottie.asset(
          isPrimary
              ? AppLotties.loadingIndicatorPrimary
              : AppLotties.loadingIndicatorWhite,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

