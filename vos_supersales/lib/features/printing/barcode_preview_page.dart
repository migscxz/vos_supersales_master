import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodePreviewPage extends StatelessWidget {
  final String documentNumber;

  const BarcodePreviewPage({super.key, required this.documentNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt Barcode Preview")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan This Receipt Number:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            BarcodeWidget(
              barcode: Barcode.code128(),
              data: documentNumber,
              width: 300,
              height: 80,
              drawText: true,
            ),
            const SizedBox(height: 20),
            Text(
              "Document #: $documentNumber",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
