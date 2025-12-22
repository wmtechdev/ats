import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobEditScreen extends StatelessWidget {
  const AdminJobEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminJobsController>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final hospitalController = TextEditingController();

    return AdminMainLayout(
      title: AppTexts.editJob,
      child: Obx(() {
        final job = controller.selectedJob.value;
        if (job == null) {
          return AppEmptyState(
            message: AppTexts.jobNotFound,
            icon: Iconsax.document,
          );
        }

        titleController.text = job.title;
        descriptionController.text = job.description;
        hospitalController.text = job.hospitalName;

        return Column(
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
            AppSpacing.vertical(context, 0.03),
            Obx(() => AppButton(
                  text: AppTexts.updateJob,
                  icon: Iconsax.edit,
                  onPressed: () {
                    controller.updateJob(
                      jobId: job.jobId,
                      title: titleController.text,
                      description: descriptionController.text,
                      hospitalName: hospitalController.text,
                    );
                  },
                  isLoading: controller.isLoading.value,
                )),
          ],
        );
      }),
    );
  }
}
