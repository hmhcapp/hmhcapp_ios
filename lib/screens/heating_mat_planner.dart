import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HeatingMatPlannerScreen extends StatefulWidget {
  const HeatingMatPlannerScreen({super.key});

  @override
  State<HeatingMatPlannerScreen> createState() =>
      _HeatingMatPlannerScreenState();
}

class _HeatingMatPlannerScreenState extends State<HeatingMatPlannerScreen> {
  static const _plannerUrl = String.fromEnvironment(
    'HEATMAT_PLANNER_URL',
    defaultValue: 'https://app.heatmat.co.uk',
  );

  late final Uri _initialUri = Uri.parse(_plannerUrl);
  late final WebViewController _controller;

  int _progress = 0;
  String? _loadError;
  bool _savingPdf = false;

  String? _transferId;
  String _pdfFileName = 'HEATMAT_installation_recommendations.pdf';
  int _expectedBytes = 0;
  int _expectedChunks = 0;
  int _receivedChunks = 0;
  BytesBuilder? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _hideAndroidNavigationBar();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111111))
      ..addJavaScriptChannel(
        'HeatMatBridge',
        onMessageReceived: (message) => _handleBridgeMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _progress = 0;
                _loadError = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _loadError = error.description);
            }
          },
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadRequest(_initialUri);
  }

  @override
  void dispose() {
    _restoreSystemNavigation();
    super.dispose();
  }

  void _hideAndroidNavigationBar() {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.top],
    );
  }

  void _restoreSystemNavigation() {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    if (!request.isMainFrame) return NavigationDecision.navigate;

    if (_isPlannerUri(uri)) return NavigationDecision.navigate;

    if (uri.scheme == 'tel' || uri.scheme == 'mailto') {
      _openExternally(uri);
      return NavigationDecision.prevent;
    }

    if (uri.scheme == 'https') {
      _openExternally(uri);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.prevent;
  }

  bool _isPlannerUri(Uri uri) {
    if (uri.scheme == 'about' || uri.scheme == 'blob') return true;

    final sameConfiguredOrigin =
        uri.scheme == _initialUri.scheme &&
        uri.host == _initialUri.host &&
        uri.port == _initialUri.port;

    return sameConfiguredOrigin ||
        (uri.scheme == 'https' && uri.host == 'app.heatmat.co.uk');
  }

  Future<void> _openExternally(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) _showMessage('Unable to open this link.');
  }

  Future<void> _handleBridgeMessage(String rawMessage) async {
    try {
      final message = jsonDecode(rawMessage) as Map<String, dynamic>;
      final type = message['type'] as String?;
      final id = message['transferId'] as String?;

      switch (type) {
        case 'pdf-start':
          _transferId = id;
          _pdfFileName = _safePdfFileName(message['fileName'] as String?);
          _expectedBytes = (message['byteLength'] as num?)?.toInt() ?? 0;
          _expectedChunks = (message['totalChunks'] as num?)?.toInt() ?? 0;
          _receivedChunks = 0;
          _pdfBytes = BytesBuilder(copy: false);
          if (mounted) setState(() => _savingPdf = true);
          break;

        case 'pdf-chunk':
          if (id != _transferId || _pdfBytes == null) return;
          _pdfBytes!.add(base64Decode(message['data'] as String));
          _receivedChunks += 1;
          break;

        case 'pdf-complete':
          if (id != _transferId || _pdfBytes == null) return;
          await _finishPdfTransfer();
          break;

        case 'pdf-error':
          if (id == _transferId) {
            _resetPdfTransfer();
            _showMessage(
              message['message'] as String? ?? 'Unable to prepare the PDF.',
            );
          }
          break;
      }
    } catch (_) {
      _resetPdfTransfer();
      _showMessage('Unable to receive the PDF from the planner.');
    }
  }

  Future<void> _finishPdfTransfer() async {
    final bytes = _pdfBytes!.takeBytes();
    final validTransfer =
        bytes.isNotEmpty &&
        (_expectedBytes == 0 || bytes.length == _expectedBytes) &&
        (_expectedChunks == 0 || _receivedChunks == _expectedChunks);

    if (!validTransfer) {
      _resetPdfTransfer();
      _showMessage('The PDF transfer was incomplete. Please try again.');
      return;
    }

    try {
      final previewPath = await _writePdfPreview(bytes);
      final savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: bytes,
          fileName: _pdfFileName,
          mimeTypesFilter: const ['application/pdf'],
        ),
      );

      if (savedPath == null || savedPath.isEmpty) {
        _showMessage('Save cancelled.');
      } else {
        _showPdfSaved(previewPath);
      }
    } catch (_) {
      _showMessage('Unable to save the PDF. Please try again.');
    } finally {
      _resetPdfTransfer();
    }
  }

  String _safePdfFileName(String? value) {
    final original = value?.trim().isNotEmpty == true
        ? value!.trim()
        : 'HEATMAT_installation_recommendations.pdf';
    final safe = original.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return safe.toLowerCase().endsWith('.pdf') ? safe : '$safe.pdf';
  }

  Future<String> _writePdfPreview(Uint8List bytes) async {
    final temporaryDirectory = await getTemporaryDirectory();
    final previewFile = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}$_pdfFileName',
    );
    await previewFile.writeAsBytes(bytes, flush: true);
    return previewFile.path;
  }

  void _resetPdfTransfer() {
    _transferId = null;
    _pdfBytes = null;
    _expectedBytes = 0;
    _expectedChunks = 0;
    _receivedChunks = 0;
    if (mounted) setState(() => _savingPdf = false);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPdfSaved(String previewPath) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('PDF saved to your device.'),
          duration: const Duration(seconds: 12),
          action: SnackBarAction(
            label: 'VIEW PDF',
            onPressed: () => _openSavedPdf(previewPath),
          ),
        ),
      );
  }

  Future<void> _openSavedPdf(String savedPath) async {
    final result = await OpenFilex.open(savedPath, type: 'application/pdf');
    if (result.type != ResultType.done) {
      _showMessage('Unable to open the saved PDF.');
    }
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _retry() {
    setState(() => _loadError = null);
    _controller.loadRequest(_initialUri);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          title: const Text('Heating Mat Planner'),
          actions: [
            IconButton(
              tooltip: 'Restart planner',
              onPressed: () => _controller.loadRequest(_initialUri),
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: _progress < 100 && _loadError == null
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(value: _progress / 100),
                )
              : null,
        ),
        body: Stack(
          children: [
            if (_loadError == null)
              WebViewWidget(controller: _controller)
            else
              _PlannerLoadError(onRetry: _retry),
            if (_savingPdf)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Preparing PDF…'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlannerLoadError extends StatelessWidget {
  const _PlannerLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'The Heating Mat Planner needs an internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
