import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobCreateScreen extends StatelessWidget {
  const AdminJobCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminJobsController>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final hospitalController = TextEditingController();
    final requirementsController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(title: AppTexts.createJob),
      body: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          children: [
            AppTextField(
              controller: titleController,
              labelText: AppTexts.jobTitle,
              prefixIcon: Iconsax.briefcase,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: descriptionController,
              labelText: AppTexts.description,
              prefixIcon: Iconsax.document_text,
              maxLines: 5,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: hospitalController,
              labelText: AppTexts.hospitalName,
              prefixIcon: Iconsax.hospital,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: requirementsController,
              labelText: AppTexts.requirementsCommaSeparated,
              prefixIcon: Iconsax.tick_circle,
            ),
            AppSpacing.vertical(context, 0.03),
            Obx(() => AppButton(
                  text: AppTexts.createJob,
                  icon: Iconsax.add,
                  onPressed: () {
                    final requirements = requirementsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    controller.createJob(
                      title: titleController.text,
                      description: descriptionController.text,
                      hospitalName: hospitalController.text,
                      requirements: requirements,
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
