class ApiConstants {
  static const String baseUrl = 'http://192.168.1.49:8080/api';

  // Auth
  static const String login = '$baseUrl/sales-invoices/salesman';

  // Users
  static const String users = '$baseUrl/users';

  // Salesmen
  static const String salesmen = '$baseUrl/salesmen';

  // Customers
  static const String customers = '$baseUrl/customers'; // GET
  static const String createCustomer = '$baseUrl/customers'; // POST

  // Products
  static const String products = '$baseUrl/products';

  // Sales Invoices
  static const String salesInvoices = '$baseUrl/sales-invoices';

  // Productive Outlet Photos
  static const String uploadPhoto = '$baseUrl/productive-outlet-photo';

  // Invoice Types
  static const String salesInvoiceTypes = '$baseUrl/sales-invoice-types';

  // ✅ Sales Return Types
  static const String salesReturnTypes = '$baseUrl/sales-return-types';
}
