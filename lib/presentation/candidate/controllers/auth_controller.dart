import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/usecases/auth/sign_up_usecase.dart';
import 'package:ats/domain/usecases/auth/sign_in_usecase.dart';
import 'package:ats/domain/usecases/auth/sign_out_usecase.dart';
import 'package:ats/domain/usecases/auth/forgot_password_usecase.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController(this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final signUpUseCase = SignUpUseCase(Get.find<AuthRepository>());
  final signInUseCase = SignInUseCase(Get.find<AuthRepository>());
  final signOutUseCase = SignOutUseCase(Get.find<AuthRepository>());
  final forgotPasswordUseCase = ForgotPasswordUseCase(Get.find<AuthRepository>());

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await signUpUseCase(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        // Redirect based on role
        if (user.role == AppConstants.roleAdmin) {
          Get.offAllNamed(AppConstants.routeAdminDashboard);
        } else {
          Get.offAllNamed(AppConstants.routeCandidateProfile);
        }
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        // Redirect based on role
        if (user.role == AppConstants.roleAdmin) {
          Get.offAllNamed(AppConstants.routeAdminDashboard);
        } else {
          Get.offAllNamed(AppConstants.routeCandidateDashboard);
        }
      },
    );
  }

  Future<void> signOut() async {
    isLoading.value = true;
    final result = await signOutUseCase();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        Get.offAllNamed(AppConstants.routeLogin);
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await forgotPasswordUseCase(email);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        Get.snackbar('Success', 'Password reset email sent');
      },
    );
  }
}

