import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  late final TextEditingController _searchController;
  late final DocumentsController _controller;
  Widget? _cachedContent; // Cache the entire Column content
  final _searchBarKey = GlobalKey(debugLabel: 'documents-search-bar'); // GlobalKey for search bar

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DocumentsController>();
    // Create search controller and sync with controller's search query
    _searchController = TextEditingController(text: _controller.searchQuery.value);
    
    // Listen to search query changes from controller (e.g., when cleared)
    ever(_controller.searchQuery, (query) {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(
    BuildContext context,
    DocumentsController controller,
    String candidateDocId,
    String storageUrl,
    String documentName,
  ) {
    Get.dialog(
      AppAlertDialog(
        title: AppTexts.deleteDocument,
        subtitle: '${AppTexts.areYouSureDeleteDocument}: $documentName',
        primaryButtonText: AppTexts.delete,
        secondaryButtonText: AppTexts.cancel,
        onPrimaryPressed: () async {
          // Delete document - dialog will close automatically via AppAlertDialog
          await controller.deleteDocument(candidateDocId, storageUrl);
        },
        onSecondaryPressed: () {
          // Dialog will close automatically via AppAlertDialog
        },
        primaryButtonColor: AppColors.error,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cache the entire Column content to prevent search bar recreation
    // Use Builder to ensure context is available
    _cachedContent ??= Builder(
      builder: (context) => Column(
        key: const ValueKey('documents-content-column'),
        children: [
          // Search and Add Section - Use GlobalKey to preserve state
          AppSearchCreateBar(
            key: _searchBarKey, // Use GlobalKey to preserve search field state
            searchController: _searchController,
            searchHint: AppTexts.searchDocuments,
            createButtonText: AppTexts.addNewDocument,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => _controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeCandidateCreateDocument);
            },
          ),
          // Documents List
          Expanded(
            child: Obx(() {
              final adminDocs = _controller.filteredDocumentTypes.toList();
              final userDocs = _controller.filteredUserDocuments.toList();
              final hasAnyDocs = adminDocs.isNotEmpty || userDocs.isNotEmpty;

              if (!hasAnyDocs) {
                return AppEmptyState(
                  message:
                      _controller.documentTypes.isEmpty &&
                          _controller.candidateDocuments
                              .where((doc) => doc.isUserAdded)
                              .isEmpty
                      ? AppTexts.noDocumentTypesAvailable
                      : AppTexts.noDocumentsFound,
                  icon: Iconsax.document_text,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: adminDocs.length + userDocs.length,
                itemBuilder: (context, index) {
                  // Admin-provided documents first
                  if (index < adminDocs.length) {
                    final docType = adminDocs[index];

                    return Obx(() {
                      // Re-read reactive values inside Obx for this specific item
                      final isUploadingThisItem =
                          _controller.uploadingDocTypeId.value ==
                          docType.docTypeId;
                      final currentProgress = _controller.uploadProgress.value;
                      final currentHasDoc = _controller.hasDocument(
                        docType.docTypeId,
                      );
                      final currentDocument = _controller.getDocumentByType(
                        docType.docTypeId,
                      );
                      final documentStatus = currentDocument?.status ?? '';
                      final isPending =
                          documentStatus == AppConstants.documentStatusPending;
                      final isDenied =
                          documentStatus == AppConstants.documentStatusDenied;
                      final hasStorageUrl =
                          currentDocument?.storageUrl.isNotEmpty ?? false;

                      return Column(
                        children: [
                          AppListCard(
                            title: docType.name,
                            subtitle: docType.description,
                            icon: Iconsax.document_text,
                            trailing: isUploadingThisItem
                                ? SizedBox(
                                    width: 120,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        LinearProgressIndicator(
                                          value: currentProgress,
                                          backgroundColor: AppColors.grey
                                              .withValues(alpha: 0.2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                          minHeight: 6,
                                        ),
                                        AppSpacing.vertical(context, 0.005),
                                        Text(
                                          '${(currentProgress * 100).toStringAsFixed(0)}%',
                                          style: AppTextStyles.bodyText(context)
                                              .copyWith(
                                                fontSize:
                                                    AppTextStyles.bodyText(
                                                      context,
                                                    ).fontSize! *
                                                    0.75,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : currentHasDoc
                                ? null
                                : AppButton(
                                    backgroundColor: AppColors.primary,
                                    text: AppTexts.upload,
                                    icon: Iconsax.document_upload,
                                    onPressed: () => _controller.uploadDocument(
                                      docType.docTypeId,
                                      docType.name,
                                    ),
                                    isFullWidth: false,
                                  ),
                            contentBelowSubtitle: currentHasDoc
                                ? Wrap(
                                    spacing:
                                        AppResponsive.screenWidth(context) *
                                        0.01,
                                    runSpacing:
                                        AppResponsive.screenHeight(context) *
                                        0.005,
                                    children: [
                                      AppStatusChip(status: documentStatus),
                                      // Show view button when document has been uploaded
                                      if (hasStorageUrl)
                                        AppActionButton(
                                          text: AppTexts.view,
                                          onPressed: () {
                                            AppDocumentViewer.show(
                                              documentUrl:
                                                  currentDocument!.storageUrl,
                                              documentName: docType.name,
                                            );
                                          },
                                          backgroundColor:
                                              AppColors.information,
                                          foregroundColor: AppColors.white,
                                        ),
                                      // Show delete button when pending
                                      if (isPending)
                                        AppActionButton(
                                          text: AppTexts.delete,
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                _controller,
                                                currentDocument!.candidateDocId,
                                                currentDocument.storageUrl,
                                                docType.name,
                                              ),
                                          backgroundColor: AppColors.error,
                                          foregroundColor: AppColors.white,
                                        ),
                                      // Show reupload button when denied
                                      if (isDenied)
                                        AppActionButton(
                                          text: AppTexts.reupload,
                                          onPressed: () =>
                                              _controller.uploadDocument(
                                                docType.docTypeId,
                                                docType.name,
                                              ),
                                          backgroundColor: AppColors.warning,
                                          foregroundColor: AppColors.black,
                                        ),
                                    ],
                                  )
                                : null,
                            onTap: null,
                          ),
                        ],
                      );
                    });
                  } else {
                    // User-added documents
                    final userDocIndex = index - adminDocs.length;

                    return Obx(() {
                      // Re-read reactive values inside Obx for this specific item
                      // Get the current document from the reactive list
                      final currentUserDocs = _controller.filteredUserDocuments
                          .toList();
                      if (userDocIndex >= currentUserDocs.length) {
                        // Document was deleted, return empty container
                        return const SizedBox.shrink();
                      }

                      final userDoc = currentUserDocs[userDocIndex];
                      final isPending =
                          userDoc.status == AppConstants.documentStatusPending;
                      final isDenied =
                          userDoc.status == AppConstants.documentStatusDenied;
                      final hasStorageUrl = userDoc.storageUrl.isNotEmpty;
                      final expiryStatus =
                          AppCandidateTableFormatters.formatExpiryStatus(
                            userDoc,
                          );

                      return AppListCard(
                        title:
                            userDoc.title ??
                            AppFileValidator.extractOriginalFileName(
                              userDoc.documentName,
                            ),
                        subtitle: userDoc.description ?? '',
                        icon: Iconsax.document_text,
                        trailing: null,
                        contentBelowSubtitle: Wrap(
                          spacing: AppResponsive.screenWidth(context) * 0.01,
                          runSpacing:
                              AppResponsive.screenHeight(context) * 0.005,
                          children: [
                            // Expiry Status Chip
                            if (expiryStatus != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppResponsive.screenWidth(context) * 0.01,
                                  vertical:
                                      AppResponsive.screenHeight(context) *
                                      0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.expiry,
                                  borderRadius: BorderRadius.circular(
                                    AppResponsive.radius(context, factor: 5),
                                  ),
                                ),
                                child: Text(
                                  expiryStatus.toUpperCase(),
                                  style: AppTextStyles.bodyText(context)
                                      .copyWith(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ),
                            AppStatusChip(status: userDoc.status),
                            // Show view button when document has been uploaded
                            if (hasStorageUrl)
                              AppActionButton(
                                text: AppTexts.view,
                                onPressed: () {
                                  AppDocumentViewer.show(
                                    documentUrl: userDoc.storageUrl,
                                    documentName:
                                        userDoc.title ??
                                        AppFileValidator.extractOriginalFileName(
                                          userDoc.documentName,
                                        ),
                                  );
                                },
                                backgroundColor: AppColors.information,
                                foregroundColor: AppColors.white,
                              ),
                            // Show delete button when pending
                            if (isPending)
                              AppActionButton(
                                text: AppTexts.delete,
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  _controller,
                                  userDoc.candidateDocId,
                                  userDoc.storageUrl,
                                  userDoc.title ??
                                      AppFileValidator.extractOriginalFileName(
                                        userDoc.documentName,
                                      ),
                                ),
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.white,
                              ),
                            // Show reupload button when denied
                            if (isDenied)
                              AppActionButton(
                                text: AppTexts.reupload,
                                onPressed: () {
                                  // Navigate to create document screen with pre-filled data
                                  Get.toNamed(
                                    AppConstants.routeCandidateCreateDocument,
                                  );
                                },
                                backgroundColor: AppColors.warning,
                                foregroundColor: AppColors.black,
                              ),
                          ],
                        ),
                        onTap: null,
                      );
                    });
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
    
    return AppCandidateLayout(
      title: AppTexts.myDocuments,
      child: _cachedContent!,
    );
  }
}
