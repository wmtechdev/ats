import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/common/forms/app_required_label.dart';
import 'package:iconsax/iconsax.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool showPasswordToggle;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showLabelAbove;
  final bool enabled;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.showPasswordToggle = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.showLabelAbove = false,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    
    // Add focus listener
    _focusNode.addListener(_onFocusChange);
    
    // Add controller listener if controller exists
    // Use try-catch to handle disposed controllers gracefully
    if (widget.controller != null) {
      try {
        widget.controller!.addListener(_onControllerChange);
      } catch (e) {
        // Controller might be disposed, ignore
      }
    }
  }
  
  void _onFocusChange() {
    // Focus change handler
  }
  
  void _onControllerChange() {
    // Controller change handler
  }
  
  /// Get a valid controller, returning null if the controller is disposed
  TextEditingController? _getValidController() {
    if (widget.controller == null) return null;
    try {
      // Try to access the controller's value to check if it's disposed
      // If it throws, the controller is disposed
      final _ = widget.controller!.value;
      return widget.controller;
    } catch (e) {
      // Controller is disposed, return null
      return null;
    }
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controller listener if controller changed
    if (oldWidget.controller != widget.controller) {
      try {
        oldWidget.controller?.removeListener(_onControllerChange);
      } catch (e) {
        // Old controller might be disposed, ignore
      }
      try {
        widget.controller?.addListener(_onControllerChange);
      } catch (e) {
        // New controller might be disposed, ignore
      }
    }
    
    // Update obscure text if it changed
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    try {
      widget.controller?.removeListener(_onControllerChange);
    } catch (e) {
      // Controller might be disposed, ignore
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPadding = AppSpacing.symmetric(context, h: 0.04, v: 0.02);
    final contentPadding = widget.prefixIcon == null
        ? EdgeInsets.only(
            left: defaultPadding.horizontal * 0.1,
            right: defaultPadding.horizontal,
          )
        : defaultPadding;

    final textField = GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus && widget.enabled) {
          _focusNode.requestFocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: TextField(
        controller: _getValidController(),
        focusNode: _focusNode,
        obscureText: widget.obscureText ? _obscureText : false,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        enableInteractiveSelection: true,
        enableSuggestions: !widget.obscureText,
        autocorrect: !widget.obscureText,
        style: AppTextStyles.bodyText(context),
        onTapOutside: (event) {
          _focusNode.unfocus();
        },
        onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                size: AppResponsive.iconSize(context),
                color: AppColors.primary,
              )
            : null,
        suffixIcon: widget.obscureText && widget.showPasswordToggle
            ? IconButton(
                icon: Icon(
                  _obscureText ? Iconsax.eye : Iconsax.eye_slash,
                  size: AppResponsive.iconSize(context),
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        contentPadding: contentPadding,
      ),
    ));

    // If labelText is provided and showLabelAbove is true, show it above the text field
    Widget result;
    if (widget.showLabelAbove &&
        widget.labelText != null &&
        widget.labelText!.isNotEmpty) {
      final isRequired = widget.labelText!.endsWith('(*)');
      final labelText = isRequired
          ? widget.labelText!.substring(0, widget.labelText!.length - 3)
          : widget.labelText!;

      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          isRequired
              ? AppRequiredLabel(text: labelText)
              : Text(
                  labelText,
                  style: AppTextStyles.bodyText(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
          textField,
        ],
      );
    } else {
      result = textField;
    }
    
    return result;
  }
}
