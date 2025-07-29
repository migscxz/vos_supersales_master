import 'package:flutter/material.dart';
import '../core/printing/blue_print_pos_service.dart';
import '../core/printing/receipt_builder.dart';

class SelectPrinterPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final double total;
  final String customerName;
  final String customerAddress;
  final String date;
  final String documentNumber; // ✅ Added

  const SelectPrinterPage({
    super.key,
    required this.cart,
    required this.total,
    required this.customerName,
    required this.customerAddress,
    required this.date,
    required this.documentNumber,
  });

  @override
  State<SelectPrinterPage> createState() => _SelectPrinterPageState();
}

class _SelectPrinterPageState extends State<SelectPrinterPage> {
  final BluePrintPosService service = BluePrintPosService();
  List<BlueDevice> devices = [];
  BlueDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    scan();
  }

  void scan() async {
    final found = await service.scanDevices();
    setState(() => devices = found);
  }

  void _print() async {
    if (selectedDevice == null) return;

    final connected = await service.connect(selectedDevice!);
    if (!connected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to connect.")));
      return;
    }

    final lines = ReceiptBuilder.buildReceipt(
      cart: widget.cart,
      total: widget.total,
      customerName: widget.customerName,
      customerAddress: widget.customerAddress,
      date: widget.date,
      documentNumber: widget.documentNumber,
    );

    await service.printReceipt(
      lines,
      barcode: widget.documentNumber, // This should be a unique document ID
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Printer")),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (_, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.address),
            trailing: selectedDevice == device
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => setState(() => selectedDevice = device),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _print,
          icon: const Icon(Icons.print),
          label: const Text("Print Receipt"),
        ),
      ),
    );
  }
}
