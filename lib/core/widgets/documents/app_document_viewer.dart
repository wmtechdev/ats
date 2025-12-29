import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';

// Conditional imports for web - use stubs for WebAssembly builds  
import 'package:ats/core/widgets/documents/html_stub.dart' as html
    if (dart.library.html) 'dart:html' show window, AnchorElement, IFrameElement, document;
import 'package:ats/core/widgets/documents/ui_web_stub.dart' as ui_web
    if (dart.library.html) 'dart:ui_web';

class AppDocumentViewer extends StatelessWidget {
  final String documentUrl;
  final String? documentName;

  const AppDocumentViewer({
    super.key,
    required this.documentUrl,
    this.documentName,
  });

  /// Shows the document viewer in a dialog
  static void show({
    required String documentUrl,
    String? documentName,
  }) {
    Get.dialog(
      AppDocumentViewer(
        documentUrl: documentUrl,
        documentName: documentName,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  /// Determines the file type from URL
  String _getFileType(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.pdf')) return 'pdf';
    if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg')) return 'image';
    if (lowerUrl.contains('.png')) return 'image';
    if (lowerUrl.contains('.gif')) return 'image';
    if (lowerUrl.contains('.doc') || lowerUrl.contains('.docx')) return 'document';
    if (lowerUrl.contains('.txt')) return 'text';
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    final fileType = _getFileType(documentUrl);

    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, factor: 1.5)),
      ),
      child: Container(
        width: AppResponsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.95
            : MediaQuery.of(context).size.width * 0.85,
        height: AppResponsive.isMobile(context)
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.9,
        padding: AppSpacing.all(context, factor: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    documentName ?? AppTexts.documentFile,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.horizontal(context, 0.02),
                IconButton(
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.white,
                    size: AppResponsive.iconSize(context) * 1.2,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            AppSpacing.vertical(context, 0.02),
            // Document content
            Expanded(
              child: _buildDocumentContent(context, fileType),
            ),
            AppSpacing.vertical(context, 0.02),
            // Footer actions
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                TextButton.icon(
                  onPressed: () => _openInNewTab(documentUrl),
                  icon: Icon(
                    Iconsax.export,
                    color: AppColors.primary,
                    size: AppResponsive.iconSize(context),
                  ),
                  label: Text(
                    AppTexts.openInNewTab,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _downloadDocument(documentUrl, documentName),
                  icon: Icon(
                    Iconsax.document_download,
                    color: AppColors.primary,
                    size: AppResponsive.iconSize(context),
                  ),
                  label: Text(
                    AppTexts.download,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentContent(BuildContext context, String fileType) {
    switch (fileType) {
      case 'pdf':
        return _buildPdfViewer(context);
      case 'image':
        return _buildImageViewer(context);
      case 'text':
        return _buildTextViewer(context);
      case 'document':
        return _buildDocumentViewer(context);
      default:
        return _buildUnsupportedViewer(context);
    }
  }

  Widget _buildPdfViewer(BuildContext context) {
    if (kIsWeb) {
      // Use iframe for web PDF viewing
      final iframeId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
      
      // Register the iframe
      ui_web.platformViewRegistry.registerViewFactory(
        iframeId,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = documentUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
          return iframe;
        },
      );

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          child: HtmlElementView(viewType: iframeId),
        ),
      );
    } else {
      // For mobile, show a message with link
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text,
              size: AppResponsive.iconSize(context) * 3,
              color: AppColors.primary,
            ),
            AppSpacing.vertical(context, 0.02),
            Text(
              AppTexts.pdfViewerNotAvailable,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.02),
            ElevatedButton.icon(
              onPressed: () => _openInNewTab(documentUrl),
              icon: Icon(Iconsax.export),
              label: Text(AppTexts.openInBrowser),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImageViewer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            documentUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.danger,
                      size: AppResponsive.iconSize(context) * 2,
                      color: AppColors.error,
                    ),
                    AppSpacing.vertical(context, 0.01),
                    Text(
                      AppTexts.failedToLoadImage,
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextViewer(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchTextContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.danger,
                  size: AppResponsive.iconSize(context) * 2,
                  color: AppColors.error,
                ),
                AppSpacing.vertical(context, 0.01),
                Text(
                  AppTexts.failedToLoadDocument,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          ),
          padding: AppSpacing.all(context),
          child: SingleChildScrollView(
            child: Text(
              snapshot.data ?? '',
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.black,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentViewer(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_text,
            size: AppResponsive.iconSize(context) * 3,
            color: AppColors.primary,
          ),
          AppSpacing.vertical(context, 0.02),
          Text(
            AppTexts.documentPreviewNotAvailable,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.02),
          ElevatedButton.icon(
            onPressed: () => _openInNewTab(documentUrl),
            icon: Icon(Iconsax.export),
            label: Text(AppTexts.openInBrowser),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedViewer(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_text,
            size: AppResponsive.iconSize(context) * 3,
            color: AppColors.primary,
          ),
          AppSpacing.vertical(context, 0.02),
          Text(
            AppTexts.documentTypeNotSupported,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.02),
          ElevatedButton.icon(
            onPressed: () => _downloadDocument(documentUrl, documentName),
            icon: Icon(Iconsax.document_download),
            label: Text(AppTexts.download),
          ),
        ],
      ),
    );
  }

  Future<String> _fetchTextContent() async {
    if (!kIsWeb) {
      throw UnsupportedError('Text fetching not supported on mobile');
    }
    try {
      final response = await html.window.fetch(documentUrl);
      return await response.text();
    } catch (e) {
      throw Exception('Failed to fetch text content: $e');
    }
  }

  void _openInNewTab(String url) {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      // For mobile, you might want to use url_launcher package
      // For now, just show a message
      Get.snackbar(
        AppTexts.info,
        'Please open the URL manually: $url',
      );
    }
  }

  void _downloadDocument(String url, String? fileName) {
    if (kIsWeb) {
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = fileName ?? 'document';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
    } else {
      Get.snackbar(
        AppTexts.info,
        'Download functionality not available on mobile. Please use the browser.',
      );
    }
  }
}

