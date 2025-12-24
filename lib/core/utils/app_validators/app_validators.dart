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
    if (value.length < 6) {
      return AppTexts.passwordMinLength;
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
}

