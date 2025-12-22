import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/usecases/candidate_profile/create_profile_usecase.dart';

class ProfileController extends GetxController {
  final CandidateProfileRepository profileRepository;
  final AuthRepository authRepository;

  ProfileController(this.profileRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final profile = Rxn<CandidateProfileEntity>();

  final createProfileUseCase = CreateProfileUseCase(Get.find<CandidateProfileRepository>());

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    profileRepository.streamProfile(currentUser.userId).listen((profileData) {
      profile.value = profileData;
    });
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

