import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:image/image.dart' as img;

/// Generates a barcode image (as PNG) using Barcode.code128
Future<Uint8List> generateBarcodeImage(String data) async {
  final Barcode barcode = Barcode.code128();
  const int width = 400;
  const int height = 100;

  final image = img.Image(width: width, height: height);
  image.fill(img.ColorRgb8(255, 255, 255)); // Fill with white background

  // Draw the barcode on the image
  barcode.drawBarcode(
    image,
    data,
    drawText: false, // Set to true if you want text shown below
  );

  final pngBytes = img.encodePng(image);
  return Uint8List.fromList(pngBytes);
}

extension on Barcode {
  void drawBarcode(img.Image image, String data, {required bool drawText}) {}
}

extension on img.Image {
  void fill(img.ColorRgb8 colorRgb8) {}
}
