enum PasswordStrength { weak, medium, strong }

class PasswordStrengthCalculator {
  PasswordStrengthCalculator._();

  /// Calculates password strength based on various criteria
  /// Returns PasswordStrength enum (weak, medium, strong)
  static PasswordStrength calculateStrength(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Length checks
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score += 1; // lowercase
    if (password.contains(RegExp(r'[A-Z]'))) score += 1; // uppercase
    if (password.contains(RegExp(r'[0-9]'))) score += 1; // digit
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      score += 1; // special character
    }

    // Determine strength based on score
    if (score <= 3) {
      return PasswordStrength.weak;
    } else if (score <= 5) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.strong;
    }
  }

  /// Gets the strength percentage (0.0 to 1.0)
  static double getStrengthPercentage(String? password) {
    final strength = calculateStrength(password);
    switch (strength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  /// Gets the strength label text
  static String getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}
