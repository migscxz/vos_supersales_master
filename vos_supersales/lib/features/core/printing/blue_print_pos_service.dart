import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'barcode_helper.dart';

class BlueDevice {
  final String name;
  final String address;

  BlueDevice(this.name, this.address);
}

class BluePrintPosService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<bool> _checkPermissions() async {
    final bluetooth = await Permission.bluetoothConnect.request();
    final scan = await Permission.bluetoothScan.request();
    final location = await Permission.locationWhenInUse.request();

    return bluetooth.isGranted && scan.isGranted && location.isGranted;
  }

  Future<List<BlueDevice>> scanDevices() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return [];

    final bonded = await _printer.getBondedDevices();
    return bonded
        .map((d) => BlueDevice(d.name ?? '', d.address ?? ''))
        .toList();
  }

  Future<bool> connect(BlueDevice device) async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return false;

    final result = await _printer.connect(
      BluetoothDevice(device.name, device.address),
    );
    return result == true;
  }

  Future<void> printReceipt(
    List<String> lines, {
    required String barcode,
  }) async {
    for (final line in lines) {
      await _printer.printCustom(line, 1, 0); // Size 1, align left
    }

    await _printer.printNewLine();

    // ✅ Generate and print barcode as image
    try {
      Uint8List barcodeImage = await generateBarcodeImage(barcode);
      await _printer.printImageBytes(barcodeImage);
    } catch (e) {
      print('❌ Failed to generate or print barcode: $e');
    }

    await _printer.printNewLine();
    await _printer.paperCut(); // Works only if supported
  }
}
