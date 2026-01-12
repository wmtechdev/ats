import 'package:ats/core/utils/app_texts/app_texts.dart';

class AppValidators {
  AppValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.emailRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return AppTexts.emailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.passwordRequired;
    }

    // Minimum length check
    if (value.length < 8) {
      return AppTexts.passwordMinLength;
    }

    // Check for uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppTexts.passwordMustContainUppercase;
    }

    // Check for lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppTexts.passwordMustContainLowercase;
    }

    // Check for digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppTexts.passwordMustContainDigit;
    }

    // Check for special character
    if (!value.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      return AppTexts.passwordMustContainSymbol;
    }

    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.firstNameRequired;
    }
    if (value.trim().length < 2) {
      return AppTexts.firstNameMinLength;
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.lastNameRequired;
    }
    if (value.trim().length < 2) {
      return AppTexts.lastNameMinLength;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.phoneRequired;
    }
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return AppTexts.phoneInvalid;
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.addressRequired;
    }
    if (value.trim().length < 5) {
      return AppTexts.addressMinLength;
    }
    return null;
  }

  static String? validateCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.companyRequired;
    }
    if (value.trim().length < 2) {
      return AppTexts.companyMinLength;
    }
    return null;
  }

  static String? validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.positionRequired;
    }
    if (value.trim().length < 2) {
      return AppTexts.positionMinLength;
    }
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.cityRequired;
    }
    if (value.trim().length < 2) {
      return AppTexts.cityMinLength;
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.stateRequired;
    }
    return null;
  }

  static String? validateZip(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.zipRequired;
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 5) {
      return AppTexts.zipMinLength;
    }
    return null;
  }

  static String? validateAddress1(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.address1Required;
    }
    if (value.trim().length < 5) {
      return AppTexts.address1MinLength;
    }
    return null;
  }

  static String? validateProfession(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.professionRequired;
    }
    return null;
  }

  static String? validateSpecialties(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.specialtiesRequired;
    }
    return null;
  }

  static String? validateLicensureState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.licensureStateRequired;
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppTexts.phoneNumberRequired;
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return AppTexts.phoneNumberMinLength;
    }
    return null;
  }
}
