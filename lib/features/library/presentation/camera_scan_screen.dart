import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/services/ocr_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';

/// B34 — Camera-to-Quiz. Live camera preview, capture one or more pages,
/// then a mandatory review step (OCR is never perfect) before the extracted
/// text is handed back to the caller for Library ingestion. Pops with the
/// final, learner-edited text (a `String`), or `null` if cancelled.
class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

enum _CameraInitError { permissionDenied, noCamera, initFailed }

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;
  final List<String> _capturedPaths = [];
  bool _initializing = true;
  _CameraInitError? _error;
  bool _reviewing = false;
  bool _processingOcr = false;
  String? _ocrError;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _error = _CameraInitError.permissionDenied);
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _error = _CameraInitError.noCamera);
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _error = _CameraInitError.initFailed);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || controller.value.isTakingPicture) {
      return;
    }
    try {
      final file = await controller.takePicture();
      if (mounted) setState(() => _capturedPaths.add(file.path));
    } catch (_) {
      // Best-effort; a single failed capture shouldn't crash the session.
    }
  }

  void _removePage(int index) {
    setState(() => _capturedPaths.removeAt(index));
  }

  Future<void> _finishScanning() async {
    if (_capturedPaths.isEmpty || _processingOcr) return;
    setState(() {
      _processingOcr = true;
      _ocrError = null;
    });
    final ocr = OcrService();
    try {
      final text = await ocr.recognizePages(List.of(_capturedPaths));
      if (!mounted) return;
      _textController.text = text;
      setState(() {
        _reviewing = true;
        _processingOcr = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _processingOcr = false;
          _ocrError = context.l10n.cameraScanOcrFailed;
        });
      }
    } finally {
      await ocr.dispose();
    }
  }

  void _confirmImport() {
    Navigator.of(context).pop(_textController.text.trim());
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textController.dispose();
    super.dispose();
  }

  String _errorMessage(AppLocalizations l10n, _CameraInitError error) => switch (error) {
        _CameraInitError.permissionDenied => l10n.cameraScanPermissionDenied,
        _CameraInitError.noCamera => l10n.cameraScanNoCamera,
        _CameraInitError.initFailed => l10n.cameraScanInitFailed,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_reviewing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.cameraScanReviewTitle)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _textController.text.trim().isEmpty ? l10n.cameraScanEmptyText : l10n.cameraScanReviewHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _textController,
                  builder: (context, value, _) => PrimaryButton(
                    label: l10n.cameraScanConfirmButton,
                    onPressed: value.text.trim().isEmpty ? null : _confirmImport,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final error = _error;
    if (error != null || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.cameraScanTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error != null ? _errorMessage(l10n, error) : l10n.cameraScanInitFailed,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cameraScanTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: CameraPreview(_controller!)),
            if (_ocrError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(_ocrError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            if (_capturedPaths.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _capturedPaths.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_capturedPaths[index]),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            icon: const Icon(Icons.cancel_rounded, size: 20),
                            onPressed: () => _removePage(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _capture,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(l10n.cameraScanCaptureButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _capturedPaths.isEmpty || _processingOcr ? null : _finishScanning,
                      icon: _processingOcr
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(l10n.cameraScanDoneButton(_capturedPaths.length)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
