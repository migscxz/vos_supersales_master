import 'package:flutter/material.dart';
import 'add_customer_page.dart';
import 'customer/customer_model.dart';
import 'customer/customer_service.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_model.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_type_service.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_type_model.dart';

class SelectCustomerPage extends StatefulWidget {
  const SelectCustomerPage({super.key});

  @override
  State<SelectCustomerPage> createState() => _SelectCustomerPageState();
}

class _SelectCustomerPageState extends State<SelectCustomerPage> {
  List<Customer> _customers = [];
  List<SalesInvoiceType> _invoiceTypes = [];
  SalesInvoiceType? _selectedInvoiceType;
  String? selectedProvince;
  String? selectedCity;
  String searchQuery = '';

  final Map<String, List<String>> cityMap = {};

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadInvoiceTypes();
  }

  Future<void> _loadCustomers() async {
    final customers = await CustomerService().getAllCustomers();
    final map = <String, Set<String>>{};

    for (final customer in customers) {
      final province = customer.province ?? 'Unknown';
      final city = customer.city ?? 'Unknown';
      map.putIfAbsent(province, () => {}).add(city);
    }

    setState(() {
      _customers = customers;
      cityMap.clear();
      cityMap.addAll(map.map((key, value) => MapEntry(key, value.toList())));
    });
  }

  Future<void> _loadInvoiceTypes() async {
    try {
      final types = await SalesInvoiceTypeService().getInvoiceTypesOffline();
      setState(() => _invoiceTypes = types);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load invoice types: $e')),
      );
    }
  }

  Future<void> _addNewCustomer() async {
    if (_selectedInvoiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select invoice type first')),
      );
      return;
    }

    final newCustomer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerPage(existingCustomers: _customers),
      ),
    );

    if (newCustomer != null && newCustomer is Customer) {
      await _loadCustomers();
      Navigator.pop(context, {
        'customer': newCustomer,
        'invoiceType': _selectedInvoiceType,
      });
    }
  }

  List<Customer> get filteredCustomers {
    return _customers.where((customer) {
      final matchesProvince =
          selectedProvince == null || customer.province == selectedProvince;
      final matchesCity =
          selectedCity == null || customer.city == selectedCity;
      final matchesSearch = searchQuery.isEmpty ||
          customer.customerName.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesProvince && matchesCity && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final availableCities =
    selectedProvince != null ? cityMap[selectedProvince!] ?? [] : [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Select Customer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  DropdownButtonFormField<SalesInvoiceType>(
                    value: _selectedInvoiceType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Invoice Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _invoiceTypes.map((type) {
                      return DropdownMenuItem<SalesInvoiceType>(
                        value: type,
                        child: Text(type.type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedInvoiceType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Customer',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedProvince,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Province',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            isDense: true,
                          ),
                          items: cityMap.keys
                              .map((province) => DropdownMenuItem<String>(
                            value: province,
                            child: Text(province),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedProvince = value;
                              selectedCity = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCity,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            isDense: true,
                          ),
                          items: availableCities
                              .map((city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredCustomers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        customer.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${customer.brgy ?? ''}, ${customer.city ?? ''}, ${customer.province ?? ''}',
                      ),
                      onTap: () {
                        if (_selectedInvoiceType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select invoice type first'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context, {
                          'customer': customer,
                          'invoiceType': _selectedInvoiceType,
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addNewCustomer,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
