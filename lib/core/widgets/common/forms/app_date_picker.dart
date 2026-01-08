import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/common/forms/app_required_label.dart';

/// Date picker widget with consistent styling
class AppDatePicker extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool showLabelAbove;
  final bool enabled;
  final DateFormat? dateFormat;
  final bool monthYearOnly; // For expiry dates (MM/YYYY)

  const AppDatePicker({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
    this.showLabelAbove = false,
    this.enabled = true,
    this.dateFormat,
    this.monthYearOnly = false,
  });

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled) return;

    final DateTime now = DateTime.now();
    final DateTime first = firstDate ?? DateTime(1900);
    final DateTime last = lastDate ?? DateTime(now.year + 100);

    // Parse initial date from controller if available
    DateTime initial = initialDate ?? now;
    if (controller != null && controller!.text.isNotEmpty) {
      try {
        final format =
            dateFormat ??
            (monthYearOnly ? DateFormat('MM/yyyy') : DateFormat('yyyy-MM-dd'));
        initial = format.parse(controller!.text);
      } catch (e) {
        // Invalid date, use now
        initial = now;
      }
    }

    DateTime? picked;

    if (monthYearOnly) {
      // Show year and month picker
      picked = await showMonthYearPicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
    } else {
      // Show custom date picker matching the screenshot design
      picked = await showCustomDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
    }

    if (picked != null && controller != null) {
      final format =
          dateFormat ??
          (monthYearOnly ? DateFormat('MM/yyyy') : DateFormat('yyyy-MM-dd'));
      final formattedDate = format.format(picked);
      controller!.text = formattedDate;
      onChanged?.call(formattedDate);
    }
  }

  Future<int?> showYearPicker({
    required BuildContext context,
    required int currentYear,
    required int firstYear,
    required int lastYear,
  }) async {
    int selectedYear = currentYear;
    final years = List.generate(
      lastYear - firstYear + 1,
      (index) => firstYear + index,
    );

    return showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 1.3),
                ),
              ),
              child: Container(
                width: AppResponsive.screenWidth(context) * 0.7,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  minWidth: 300,
                  maxHeight: AppResponsive.screenHeight(context) * 0.6,
                ),
                padding: AppSpacing.all(context, factor: 1.2),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 1.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Year',
                          style: AppTextStyles.heading(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.close_circle,
                            size: AppResponsive.iconSize(context, factor: 1.0),
                            color: AppColors.grey,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.015),

                    // Year grid
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2,
                          crossAxisSpacing: AppResponsive.scaleSize(context, 8),
                          mainAxisSpacing: AppResponsive.scaleSize(context, 8),
                        ),
                        itemCount: years.length,
                        itemBuilder: (context, index) {
                          final year = years[index];
                          final isSelected = selectedYear == year;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedYear = year;
                              });
                            },
                            child: Container(
                              margin: AppSpacing.all(context, factor: 0.02),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.radius(context, factor: 0.7),
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: AppResponsive.scaleSize(
                                    context,
                                    isSelected ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$year',
                                  style: AppTextStyles.bodyText(context)
                                      .copyWith(
                                        fontSize: AppResponsive.scaleSize(
                                          context,
                                          14,
                                        ),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    AppSpacing.vertical(context, 0.015),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: AppSpacing.symmetric(
                              context,
                              h: 0.02,
                              v: 0.012,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.bodyText(
                              context,
                            ).copyWith(color: AppColors.grey),
                          ),
                        ),
                        AppSpacing.horizontal(context, 0.012),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(selectedYear);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: AppSpacing.symmetric(
                              context,
                              h: 0.02,
                              v: 0.012,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radius(context, factor: 0.7),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Select',
                            style: AppTextStyles.bodyText(context).copyWith(
                              fontSize: AppResponsive.scaleSize(context, 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> showCustomDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    DateTime selectedDate = initialDate;
    DateTime currentMonth = DateTime(initialDate.year, initialDate.month);

    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get first day of month and calculate offset
            final firstDayOfMonth = DateTime(
              currentMonth.year,
              currentMonth.month,
              1,
            );
            final firstDayWeekday =
                firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
            final daysInMonth = DateTime(
              currentMonth.year,
              currentMonth.month + 1,
              0,
            ).day;

            // Calculate days from previous month to show
            final daysFromPrevMonth = (firstDayWeekday - 1) % 7;
            final prevMonth = currentMonth.subtract(const Duration(days: 1));
            final daysInPrevMonth = DateTime(
              prevMonth.year,
              prevMonth.month + 1,
              0,
            ).day;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 1.3),
                ),
              ),
              child: Container(
                width: AppResponsive.screenWidth(context) * 0.85,
                constraints: BoxConstraints(maxWidth: 400, minWidth: 300),
                padding: AppSpacing.all(context, factor: 1.2),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 1.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month header with navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Iconsax.arrow_left_2,
                            color: AppColors.primary,
                            size: AppResponsive.iconSize(context, factor: 0.8),
                          ),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            final selectedYear = await showYearPicker(
                              context: context,
                              currentYear: currentMonth.year,
                              firstYear: firstDate.year,
                              lastYear: lastDate.year,
                            );
                            if (selectedYear != null) {
                              setState(() {
                                currentMonth = DateTime(
                                  selectedYear,
                                  currentMonth.month,
                                );
                              });
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MMMM').format(currentMonth),
                                style: AppTextStyles.bodyText(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              AppSpacing.horizontal(context, 0.01),
                              Text(
                                '${currentMonth.year}',
                                style: AppTextStyles.bodyText(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              AppSpacing.horizontal(context, 0.005),
                              Icon(
                                Iconsax.arrow_down_2,
                                size: AppResponsive.iconSize(
                                  context,
                                  factor: 0.6,
                                ),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.arrow_right_2,
                            color: AppColors.primary,
                            size: AppResponsive.iconSize(context, factor: 0.8),
                          ),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.015),

                    // Days of week header
                    Row(
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                          .map(
                            (day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: AppTextStyles.bodyText(context)
                                      .copyWith(
                                        fontSize: AppResponsive.scaleSize(
                                          context,
                                          12,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // Calendar grid
                    ...List.generate(6, (weekIndex) {
                      return Row(
                        children: List.generate(7, (dayIndex) {
                          final cellIndex = weekIndex * 7 + dayIndex;
                          final dateIndex = cellIndex - daysFromPrevMonth;

                          DateTime cellDate;
                          bool isCurrentMonth = false;
                          bool isSelected = false;

                          if (cellIndex < daysFromPrevMonth) {
                            // Previous month
                            final day =
                                daysInPrevMonth -
                                daysFromPrevMonth +
                                cellIndex +
                                1;
                            cellDate = DateTime(
                              prevMonth.year,
                              prevMonth.month,
                              day,
                            );
                          } else if (dateIndex < daysInMonth) {
                            // Current month
                            final day = dateIndex + 1;
                            cellDate = DateTime(
                              currentMonth.year,
                              currentMonth.month,
                              day,
                            );
                            isCurrentMonth = true;
                            isSelected =
                                selectedDate.year == cellDate.year &&
                                selectedDate.month == cellDate.month &&
                                selectedDate.day == cellDate.day;
                          } else {
                            // Next month
                            final day = dateIndex - daysInMonth + 1;
                            cellDate = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                              day,
                            );
                          }

                          final isSelectable =
                              cellDate.isAfter(
                                firstDate.subtract(const Duration(days: 1)),
                              ) &&
                              cellDate.isBefore(
                                lastDate.add(const Duration(days: 1)),
                              );

                          return Expanded(
                            child: GestureDetector(
                              onTap: isSelectable && isCurrentMonth
                                  ? () {
                                      setState(() {
                                        selectedDate = cellDate;
                                      });
                                    }
                                  : null,
                              child: Container(
                                height: AppResponsive.scaleSize(context, 40),
                                margin: AppSpacing.all(context, factor: 0.02),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    '${cellDate.day}',
                                    style: AppTextStyles.bodyText(context)
                                        .copyWith(
                                          fontSize: AppResponsive.scaleSize(
                                            context,
                                            14,
                                          ),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColors.white
                                              : (isCurrentMonth
                                                    ? AppColors.black
                                                    : AppColors.black
                                                          .withValues(
                                                            alpha: 0.3,
                                                          )),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),

                    AppSpacing.vertical(context, 0.015),

                    // Selected date display and Set Date button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: AppSpacing.symmetric(
                              context,
                              h: 0.015,
                              v: 0.012,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radius(context, factor: 0.7),
                              ),
                            ),
                            child: Text(
                              DateFormat('dd / MM / yyyy').format(selectedDate),
                              style: AppTextStyles.bodyText(context).copyWith(
                                fontSize: AppResponsive.scaleSize(context, 14),
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.horizontal(context, 0.012),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(selectedDate);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: AppSpacing.symmetric(
                              context,
                              h: 0.02,
                              v: 0.012,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radius(context, factor: 0.7),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Set Date',
                            style: AppTextStyles.bodyText(context).copyWith(
                              fontSize: AppResponsive.scaleSize(context, 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> showMonthYearPicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    DateTime selectedDate = initialDate;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Month and Year',
                style: AppTextStyles.heading(context),
              ),
              content: Container(
                width: AppResponsive.screenWidth(context) * 0.8,
                constraints: BoxConstraints(maxWidth: 350, minWidth: 280),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Iconsax.arrow_left_2,
                            size: AppResponsive.iconSize(context, factor: 0.8),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime(
                                selectedDate.year - 1,
                                selectedDate.month,
                              );
                            });
                          },
                        ),
                        Text(
                          '${selectedDate.year}',
                          style: AppTextStyles.heading(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.arrow_right_2,
                            size: AppResponsive.iconSize(context, factor: 0.8),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime(
                                selectedDate.year + 1,
                                selectedDate.month,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.02),
                    // Month grid
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: AppResponsive.scaleSize(context, 8),
                        mainAxisSpacing: AppResponsive.scaleSize(context, 8),
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final isSelected = selectedDate.month == month;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedDate = DateTime(selectedDate.year, month);
                            });
                          },
                          child: Container(
                            margin: AppSpacing.all(context, factor: 0.04),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radius(context, factor: 0.7),
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('MMM').format(DateTime(2000, month)),
                                style: AppTextStyles.bodyText(context).copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: AppTextStyles.bodyText(context)),
                ),
                TextButton(
                  onPressed: () {
                    // Set to first day of selected month
                    final result = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      1,
                    );
                    Navigator.of(context).pop(result);
                  },
                  child: Text(
                    'OK',
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPadding = AppSpacing.symmetric(context, h: 0.04, v: 0.02);
    final contentPadding = EdgeInsets.only(
      left: defaultPadding.horizontal * 0.1,
      right: defaultPadding.horizontal,
    );

    final textField = TextField(
      controller: controller,
      enabled: false, // Always disabled to force using picker
      readOnly: true,
      style: AppTextStyles.bodyText(context),
      decoration: InputDecoration(
        hintText: hintText ?? (monthYearOnly ? 'MM/YYYY' : 'YYYY-MM-DD'),
        filled: true,
        fillColor: enabled
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.5),
        hintStyle: AppTextStyles.hintText(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppResponsive.scaleSize(context, 2),
          ),
        ),
        suffixIcon: Icon(
          Iconsax.calendar,
          size: AppResponsive.iconSize(context),
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.5),
        ),
        contentPadding: contentPadding,
      ),
    );

    final datePickerWidget = GestureDetector(
      onTap: enabled ? () => _selectDate(context) : null,
      child: AbsorbPointer(child: textField),
    );

    // If labelText is provided and showLabelAbove is true, show it above the text field
    if (showLabelAbove && labelText != null && labelText!.isNotEmpty) {
      final isRequired = labelText!.endsWith('(*)');
      final cleanLabelText = isRequired
          ? labelText!.substring(0, labelText!.length - 3)
          : labelText!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          isRequired
              ? AppRequiredLabel(text: cleanLabelText)
              : Text(
                  cleanLabelText,
                  style: AppTextStyles.bodyText(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
          datePickerWidget,
        ],
      );
    }

    return datePickerWidget;
  }
}
