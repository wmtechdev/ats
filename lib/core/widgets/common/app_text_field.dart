import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _internalController;
  TextEditingController? _externalController;
  VoidCallback? _externalControllerListener;

  @override
  void initState() {
    super.initState();
    // Always create internal controller for safety
    _internalController = TextEditingController();
    
    // If external controller provided, sync with it
    if (widget.controller != null) {
      _syncWithExternalController();
    }
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If controller changed, update sync
    if (widget.controller != oldWidget.controller) {
      _removeExternalListener();
      if (widget.controller != null) {
        _syncWithExternalController();
      }
    }
  }

  void _syncWithExternalController() {
    if (widget.controller == null) return;
    
    try {
      // Try to access controller to check if it's valid
      final _ = widget.controller!.value;
      _externalController = widget.controller;
      
      // Sync initial value
      if (_internalController.text != _externalController!.text) {
        _internalController.text = _externalController!.text;
      }
      
      // Listen to external controller changes
      _externalControllerListener = () {
        if (mounted && _externalController != null) {
          try {
            if (_internalController.text != _externalController!.text) {
              _internalController.text = _externalController!.text;
            }
          } catch (e) {
            // External controller disposed, stop listening
            _removeExternalListener();
          }
        }
      };
      _externalController!.addListener(_externalControllerListener!);
    } catch (e) {
      // External controller is disposed or invalid, ignore it
      _externalController = null;
    }
  }

  void _removeExternalListener() {
    if (_externalController != null && _externalControllerListener != null) {
      try {
        _externalController!.removeListener(_externalControllerListener!);
      } catch (e) {
        // Controller already disposed, ignore
      }
    }
    _externalController = null;
    _externalControllerListener = null;
  }

  @override
  void dispose() {
    _removeExternalListener();
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use internal controller to avoid disposal errors
    // It's synced with external controller via listener
    
    return TextField(
      controller: _internalController,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      style: AppTextStyles.bodyText(context),
      onChanged: (value) {
        // Sync with external controller if it exists and is valid
        if (_externalController != null) {
          try {
            if (_externalController!.text != value) {
              _externalController!.text = value;
            }
          } catch (e) {
            // External controller disposed, stop syncing
            _removeExternalListener();
          }
        }
        widget.onChanged?.call(value);
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
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
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                size: AppResponsive.iconSize(context),
                color: AppColors.primary,
              )
            : null,
        contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      ),
    );
  }
}

