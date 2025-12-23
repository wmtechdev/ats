import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/usecases/candidate_profile/create_profile_usecase.dart';

class ProfileController extends GetxController {
  final CandidateProfileRepository profileRepository;
  final CandidateAuthRepository authRepository;

  ProfileController(this.profileRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final profile = Rxn<CandidateProfileEntity>();

  final createProfileUseCase = CreateProfileUseCase(Get.find<CandidateProfileRepository>());

  // Stream subscription
  StreamSubscription<CandidateProfileEntity?>? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    // Cancel stream subscription to prevent permission errors after sign-out
    _profileSubscription?.cancel();
    super.onClose();
  }

  void loadProfile() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    _profileSubscription?.cancel(); // Cancel previous subscription if exists
    _profileSubscription = profileRepository.streamProfile(currentUser.userId).listen(
      (profileData) {
        profile.value = profileData;
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
  }

  Future<void> createOrUpdateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) {
      errorMessage.value = 'User not authenticated';
      isLoading.value = false;
      return;
    }

    final result = await createProfileUseCase(
      userId: currentUser.userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      workHistory: workHistory,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (profileData) {
        profile.value = profileData;
        isLoading.value = false;
        Get.snackbar('Success', 'Profile saved successfully');
        Get.offNamed(AppConstants.routeCandidateDashboard);
      },
    );
  }
}

