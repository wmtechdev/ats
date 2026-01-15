import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:ats/core/widgets/common/forms/app_dropdown_field.dart';
import 'package:ats/core/constants/profile_constants.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

/// Widget for country code picker using dropdown with flags
class AppCountryCodePicker extends StatelessWidget {
  final String? initialValue;
  final void Function(String countryCode)? onChanged;
  final String? labelText;
  final bool showLabelAbove;

  const AppCountryCodePicker({
    super.key,
    this.initialValue,
    this.onChanged,
    this.labelText,
    this.showLabelAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    // Find the country ID from the initial value (code)
    String? selectedId;
    if (initialValue != null && initialValue!.isNotEmpty) {
      try {
        final country = ProfileConstants.countryCodes.firstWhere(
          (c) => c['code'] == initialValue,
        );
        selectedId = country['id'];
      } catch (e) {
        // If not found, default to US
        selectedId = 'US';
      }
    } else {
      selectedId = 'US'; // Default to US
    }

    // Store icon size to use in dropdown items
    final iconSize = AppResponsive.iconSize(context);
    final flagWidth = iconSize * 1.2;
    final flagHeight = iconSize * 0.8;

    return AppDropDownField<String>(
      value: selectedId,
      labelText: labelText,
      showLabelAbove: showLabelAbove,
      items: ProfileConstants.countryCodes.map((country) {
        final countryId = country['id'] ?? '';
        final countryCode = country['code'] ?? '';
        final countryName = country['name'] ?? '';

        return DropdownMenuItem<String>(
          value: countryId,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Country flag
              CountryFlag.fromCountryCode(
                countryId,
                theme: ImageTheme(width: flagWidth, height: flagHeight),
              ),
              const SizedBox(width: 8),
              // Country code and name - use Flexible to prevent overflow
              Flexible(
                child: Text(
                  '$countryCode $countryName',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (id) {
        if (id != null) {
          try {
            final country = ProfileConstants.countryCodes.firstWhere(
              (c) => c['id'] == id,
            );
            onChanged?.call(country['code'] ?? '');
          } catch (e) {
            // Handle error silently
          }
        }
      },
    );
  }
}
