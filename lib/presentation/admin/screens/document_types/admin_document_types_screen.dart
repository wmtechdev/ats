import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminDocumentTypesScreen extends StatefulWidget {
  const AdminDocumentTypesScreen({super.key});

  @override
  State<AdminDocumentTypesScreen> createState() => _AdminDocumentTypesScreenState();
}

class _AdminDocumentTypesScreenState extends State<AdminDocumentTypesScreen> {
  late final TextEditingController _searchController;
  late final AdminDocumentsController _controller;
  Widget? _cachedContent;
  final _searchBarKey = GlobalKey(debugLabel: 'admin-document-types-search-bar');

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminDocumentsController>();
    _searchController = TextEditingController(text: _controller.searchQuery.value);
    
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

  @override
  Widget build(BuildContext context) {
    _cachedContent ??= Builder(
      builder: (context) => Column(
        key: const ValueKey('admin-document-types-content-column'),
        children: [
          // Search and Create Section - Use GlobalKey to preserve state
          AppSearchCreateBar(
            key: _searchBarKey,
            searchController: _searchController,
            searchHint: AppTexts.searchDocuments,
            createButtonText: AppTexts.createDocumentType,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => _controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeAdminCreateDocumentType);
            },
          ),
          // Documents List
          Expanded(
            child: Obx(() {
              final filteredDocs = _controller.filteredDocumentTypes.toList();
              final allDocs = _controller.documentTypes.toList();

              if (filteredDocs.isEmpty) {
                return AppEmptyState(
                  message: allDocs.isEmpty
                      ? AppTexts.noDocumentTypesAvailable
                      : AppTexts.noDocumentsFound,
                  icon: Iconsax.document_text,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final docType = filteredDocs[index];
                  return AppListCard(
                    title: docType.name,
                    subtitle: docType.description,
                    icon: Iconsax.document_text,
                    trailing: null,
                    contentBelowSubtitle: Wrap(
                      spacing: AppResponsive.screenWidth(context) * 0.01,
                      runSpacing: AppResponsive.screenHeight(context) * 0.005,
                      children: [
                        AppActionButton.delete(
                          onPressed: () =>
                              _controller.deleteDocumentType(docType.docTypeId),
                        ),
                      ],
                    ),
                    onTap: null,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );

    return AppAdminLayout(
      title: AppTexts.documentTypes,
      child: _cachedContent!,
    );
  }
}
