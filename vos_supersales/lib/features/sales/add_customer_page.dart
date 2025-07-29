import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/app_database.dart';
import '../sales/customer/customer_model.dart';
import '../sales/customer/customer_service.dart';
import 'package:geolocator/geolocator.dart';

class AddCustomerPage extends StatefulWidget {
  final List<Customer> existingCustomers;

  const AddCustomerPage({super.key, required this.existingCustomers});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _barangayController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _barangayController.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied.')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _saveCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();

      final isDuplicate = widget.existingCustomers.any(
            (c) => c.customerName.toLowerCase() == name.toLowerCase(),
      );

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer already exists.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final position = await _getCurrentLocation();

      final newCustomer = Customer(
        id: DateTime.now().millisecondsSinceEpoch,
        customerCode: 'TEMP-${DateTime.now().millisecondsSinceEpoch}',
        customerName: name,
        storeName: name,
        storeSignage: name,
        customerImage: '',
        brgy: _barangayController.text.trim(),
        city: 'test',
        province: 'test',
        contactNumber: _phoneController.text.trim(),
        customerEmail: 'test',
        telNumber: '',
        bankDetails: '',
        customerTin: '',
        paymentTermId: null,
        storeTypeId: 1,
        priceType: '',
        encoderId: 0,
        creditTypeId: null,
        companyCode: 0,
        isActive: true,
        isVAT: false,
        isEWT: false,
        discountTypeId: null,
        otherDetails: '',
        classificationId: null,
        latitude: position?.latitude,
        longitude: position?.longitude,
        dateEntered: DateTime.now().toIso8601String(),
        isSynced: 0,
        syncedAt: null,
      );

      await CustomerService().insertCustomerToLocalDb(newCustomer);

      final all = await CustomerService().getAllCustomers();
      for (final c in all) {
        print('📦 ${c.customerName} | Synced: ${c.isSynced}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer saved locally!'), backgroundColor: Colors.green),
      );

      Navigator.pop<Customer>(context, newCustomer);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text('Add Customer'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Store Name *',
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Store name is required'
                      : null,
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\d{7,11}$').hasMatch(value.trim())) {
                      return 'Enter a valid phone number (7–11 digits)';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _barangayController,
                  label: 'Barangay *',
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Barangay is required'
                      : null,
                ),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Save Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
