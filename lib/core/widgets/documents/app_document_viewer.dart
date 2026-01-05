import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/app_widgets.dart';

// Direct imports - no stubs needed, conditional imports handle it
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:ui_web' as ui_web if (dart.library.ui_web) 'dart:ui_web';

class AppDocumentViewer extends StatefulWidget {
  final String documentUrl;
  final String? documentName;

  const AppDocumentViewer({
    super.key,
    required this.documentUrl,
    this.documentName,
  });

  /// Shows the document viewer in a dialog
  static void show({required String documentUrl, String? documentName}) {
    Get.dialog(
      AppDocumentViewer(documentUrl: documentUrl, documentName: documentName),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  @override
  State<AppDocumentViewer> createState() => _AppDocumentViewerState();
}

class _AppDocumentViewerState extends State<AppDocumentViewer> {
  String? _iframeViewId;
  bool _uiWebAvailable = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _createIframe();
    }
  }

  void _createIframe() {
    if (!kIsWeb) return;

    _iframeViewId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      // Try to register with ui_web
      ui_web.platformViewRegistry.registerViewFactory(
        _iframeViewId!,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = widget.documentUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true;
          return iframe;
        },
      );
      _uiWebAvailable = true;
    } catch (e) {
      // ui_web not available (WebAssembly)
      _uiWebAvailable = false;
      _iframeViewId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
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
                    widget.documentName ?? AppTexts.documentFile,
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
            // PDF content
            Expanded(child: _buildPdfViewer(context)),
            AppSpacing.vertical(context, 0.02),
            // Footer actions
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                TextButton.icon(
                  onPressed: () => _openInNewTab(widget.documentUrl),
                  icon: Icon(
                    Iconsax.export,
                    color: AppColors.primary,
                    size: AppResponsive.iconSize(context),
                  ),
                  label: Text(
                    AppTexts.openInNewTab,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _downloadDocument(widget.documentUrl, widget.documentName),
                  icon: Icon(
                    Iconsax.document_download,
                    color: AppColors.primary,
                    size: AppResponsive.iconSize(context),
                  ),
                  label: Text(
                    AppTexts.download,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer(BuildContext context) {
    if (!kIsWeb) {
      // For mobile, show option to open in browser
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
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.02),
            ElevatedButton.icon(
              onPressed: () => _openInNewTab(widget.documentUrl),
              icon: Icon(Iconsax.export),
              label: Text(AppTexts.openInBrowser),
            ),
          ],
        ),
      );
    }

    // For web: show PDF in iframe if ui_web is available
    if (_uiWebAvailable && _iframeViewId != null) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          child: HtmlElementView(viewType: _iframeViewId!),
        ),
      );
    }

    // WebAssembly or ui_web not available - auto-open in new tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInNewTab(widget.documentUrl);
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Opening PDF in new tab...',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openInNewTab(String url) {
    if (kIsWeb) {
      try {
        html.window.open(url, '_blank');
      } catch (e) {
        AppSnackbar.info('Please open the URL manually: $url');
      }
    } else {
      AppSnackbar.info('Please open the URL manually: $url');
    }
  }

  void _downloadDocument(String url, String? fileName) {
    if (kIsWeb) {
      try {
        final anchor = html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = fileName ?? 'document.pdf';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
      } catch (e) {
        _openInNewTab(url);
      }
    } else {
      AppSnackbar.info(
        'Download functionality not available on mobile. Please use the browser.',
      );
    }
  }
}
