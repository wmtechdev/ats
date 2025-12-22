import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(title: AppTexts.profile),
      body: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          children: [
            AppTextField(
              controller: firstNameController,
              labelText: AppTexts.firstName,
              prefixIcon: Iconsax.user,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: lastNameController,
              labelText: AppTexts.lastName,
              prefixIcon: Iconsax.user,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: phoneController,
              labelText: AppTexts.phone,
              prefixIcon: Iconsax.call,
              keyboardType: TextInputType.phone,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: addressController,
              labelText: AppTexts.address,
              prefixIcon: Iconsax.location,
              maxLines: 3,
            ),
            AppSpacing.vertical(context, 0.03),
            Obx(() => AppButton(
                  text: AppTexts.saveProfile,
                  onPressed: () {
                    controller.createOrUpdateProfile(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                    );
                  },
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }
}
