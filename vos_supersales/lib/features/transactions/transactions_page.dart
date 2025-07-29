import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vos_supersales/features/auth/user_model.dart';
import 'package:vos_supersales/features/sales/invoice/invoice_service.dart';
import 'package:vos_supersales/features/transactions/invoice_dao.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_model.dart';
import 'package:vos_supersales/features/sales/salesman/salesman_model.dart';
import 'package:vos_supersales/features/sales/salesman/salesman_service.dart';
import 'package:vos_supersales/features/auth/global_salesman.dart';
import '../../core/theme/app_theme.dart';

class TransactionsPage extends StatefulWidget {
  final UserModel currentUser;

  const TransactionsPage({super.key, required this.currentUser});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  int selectedPeriodIndex = 0;
  late Future<List<Invoice>> _invoiceFuture;
  List<Invoice> _allInvoices = [];

  SalesmanModel? _salesman;

  @override
  void initState() {
    super.initState();
    _invoiceFuture = _loadInvoicesWithSalesman();
  }

  Future<List<Invoice>> _loadInvoicesWithSalesman() async {
    debugPrint(
      "📦 TransactionsPage initialized for user: ${widget.currentUser.fullName}",
    );

    try {
      _salesman = GlobalSalesman.getSalesman();

      if (_salesman == null) {
        debugPrint("❌ No salesman found in global context.");
        return [];
      }

      debugPrint(
        "✅ Using global salesman: ${_salesman!.salesmanName} (ID: ${_salesman!.id})",
      );

      final invoices = await InvoiceService().fetchInvoicesFromApi(
        _salesman!.id,
      );
      await InvoiceDao.insertInvoices(invoices);
      _allInvoices = invoices;
      return invoices;
    } catch (e) {
      debugPrint("🔴 Error loading invoices: $e");
      return [];
    }
  }

  List<Invoice> get filteredInvoices {
    return _allInvoices.where((invoice) {
      final customer = invoice.customerCode.toLowerCase();
      final matchesCustomer =
          customerController.text.isEmpty ||
          customer.contains(customerController.text.toLowerCase());

      final matchesArea = areaController.text.isEmpty; // Placeholder
      return matchesCustomer && matchesArea;
    }).toList();
  }

  String getCurrentWeekLabel() {
    final now = DateTime.now();
    final weekOfMonth = ((now.day - 1) / 7).floor() + 1;
    return 'Week $weekOfMonth';
  }

  @override
  Widget build(BuildContext context) {
    final monthYear = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: _buildAppBar(monthYear),
      body: FutureBuilder<List<Invoice>>(
        future: _invoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final invoices = filteredInvoices;

            return RefreshIndicator(
              onRefresh: () async {
                final reloaded = await _loadInvoicesWithSalesman();
                setState(() {
                  _invoiceFuture = Future.value(reloaded);
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: invoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final tx = invoices[index];
                        final dateStr = tx.invoiceDate;
                        final parsedDate =
                            DateTime.tryParse(dateStr) ?? DateTime(1970);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  children: [
                                    Text(
                                      tx.invoiceNo,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      DateFormat('MM/dd').format(parsedDate),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      tx.customerCode,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      '₱${tx.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.photo_camera,
                                size: 26,
                                color: tx.isReceipt == true
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  _buildBottomPeriodNavigation(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String monthYear) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(170),
      child: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentUser.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.currentUser.departmentName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      monthYear,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterField(
                        customerController,
                        'Customer',
                        Icons.person,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterField(
                        areaController,
                        'Area',
                        Icons.location_on,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white70, size: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBottomPeriodNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: selectedPeriodIndex > 0
                ? () => setState(() => selectedPeriodIndex--)
                : null,
          ),
          Text(
            getCurrentWeekLabel(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: selectedPeriodIndex < 3
                ? () => setState(() => selectedPeriodIndex++)
                : null,
          ),
        ],
      ),
    );
  }
}
