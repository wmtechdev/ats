import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppCandidateProfileTable extends StatelessWidget {
  final String name;
  final String email;
  final String workHistory;
  final int documentsCount;
  final int applicationsCount;

  const AppCandidateProfileTable({
    super.key,
    required this.name,
    required this.email,
    required this.workHistory,
    required this.documentsCount,
    required this.applicationsCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context).copyWith(left: 0, right: 0),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(AppColors.lightGrey),
          columns: [
            DataColumn(
              label: Text(
                AppTexts.field,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                AppTexts.value,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(
                  Text(AppTexts.name, style: AppTextStyles.bodyText(context)),
                ),
                DataCell(Text(name, style: AppTextStyles.bodyText(context))),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Text(AppTexts.email, style: AppTextStyles.bodyText(context)),
                ),
                DataCell(Text(email, style: AppTextStyles.bodyText(context))),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Text(
                    AppTexts.workHistory,
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 200,
                      maxWidth: double.infinity,
                    ),
                    child: Text(
                      workHistory,
                      style: AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Text(
                    AppTexts.documentsUploadedCount,
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
                DataCell(
                  Text(
                    documentsCount.toString(),
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Text(
                    AppTexts.jobsAppliedCount,
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
                DataCell(
                  Text(
                    applicationsCount.toString(),
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
