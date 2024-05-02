import 'dart:async';

import 'package:flutter/material.dart';

import 'package:login_flutter/qrcode/scan_widget.dart';
import 'package:login_flutter/util/toast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
      torchEnabled: false,
      // useNewCameraSelector: true,
      formats: [BarcodeFormat.qrCode]
      // facing: CameraFacing.front,
      // detectionSpeed: DetectionSpeed.normal
      // detectionTimeoutMs: 1000,
      // returnImage: false,
      );

  StreamSubscription<Object?>? _subscription;
  Barcode? _barcode;

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.

    unawaited(controller.start());
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    final newIncomingBarcode = barcodes.barcodes.firstOrNull;
    if (_barcode != null &&
        newIncomingBarcode?.displayValue == _barcode?.displayValue) {
      return;
    }

    _barcode = newIncomingBarcode;
    debugPrint('扫描到 QR 码');

    // controller.stop();
    if (mounted) {
      setState(() {
        // _showSnackBar('qr code = ${_barcode?.displayValue}');
        _showToast('qr code = ${_barcode?.displayValue}');
      });
    }
  }

  Future<void> _showToast(String message) async {
    await MyToast.showToast(msg: message, type: ToastType.success);

    _barcode = null;
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 300,
      height: 300,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error, child) {
                return ScannerErrorWidget(error: error);
              },
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlay(scanWindow: scanWindow),
            ),
          ),
        ],
      ),
    );
  }
}
