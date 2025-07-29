import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vos_supersales-master.db');

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createCoreTables(db);
    await _createInvoiceTables(db);
    await _createCustomerTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createCoreTables(db);
    if (oldVersion < 3) await _createInvoiceTables(db);
    if (oldVersion < 4 || oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS salesmen');
      await _createSalesmanTable(db);
    }
    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS invoices');
      await db.execute('DROP TABLE IF EXISTS invoice_details');
      await _createInvoiceTables(db);
    }
    if (oldVersion < 7) {
      await _createCustomerTable(db);
    }
  }

  Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE products (
        productId INTEGER PRIMARY KEY,
        parentId INTEGER,
        productName TEXT,
        barcode TEXT,
        shortDescription TEXT,
        unit TEXT,
        unitId INTEGER,
        unitCount INTEGER,
        priceA REAL,
        priceB REAL,
        priceC REAL,
        priceD REAL,
        priceE REAL,
        brandName TEXT,
        categoryName TEXT,
        supplierId INTEGER,
        isActive INTEGER,
        isSynced INTEGER,
        syncedAt TEXT,
        lastUpdated TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        user_id INTEGER PRIMARY KEY,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        department_name TEXT NOT NULL,
        position TEXT NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''');

    await _createSalesmanTable(db);
  }

  Future<void> _createSalesmanTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS salesmen (
        id INTEGER PRIMARY KEY,
        employee_id INTEGER,
        salesmanCode TEXT,
        salesmanName TEXT,
        truckPlate TEXT,
        divisionId INTEGER,
        companyCode INTEGER,
        supplierCode INTEGER,
        priceType TEXT,
        isActive INTEGER,
        isInventory INTEGER,
        canCollect INTEGER,
        inventoryDay INTEGER,
        encoderId INTEGER,
        goodBranchId INTEGER,
        badBranchId INTEGER,
        operationId INTEGER,
        isSynced INTEGER
      )
    ''');
  }

  Future<void> _createInvoiceTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoices (
        invoiceId INTEGER PRIMARY KEY,
        orderId TEXT,
        customerCode TEXT,
        invoiceNo TEXT,
        salesmanId INTEGER,
        invoiceDate TEXT,
        dispatchDate TEXT,
        dueDate TEXT,
        paymentTerms INTEGER,
        transactionStatus TEXT,
        paymentStatus TEXT,
        totalAmount REAL,
        salesType INTEGER,
        invoiceTypeId INTEGER,
        invoiceType TEXT,
        invoiceTypeShortcut TEXT,
        priceType TEXT,
        vatAmount REAL,
        grossAmount REAL,
        discountAmount REAL,
        netAmount REAL,
        createdBy INTEGER,
        createdDate TEXT,
        modifiedBy INTEGER,
        modifiedDate TEXT,
        postedBy INTEGER,
        postedDate TEXT,
        remarks TEXT,
        isReceipt INTEGER,
        isPosted INTEGER,
        isDispatched INTEGER,
        isRemitted TEXT,
        isSynced INTEGER,
        syncedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoice_details (
        detailId INTEGER PRIMARY KEY,
        orderId TEXT,
        serialNo TEXT,
        discountType TEXT,
        productId INTEGER,
        productName TEXT,
        unit INTEGER,
        unitPrice REAL,
        quantity INTEGER,
        discountAmount REAL,
        grossAmount REAL,
        totalAmount REAL,
        createdDate TEXT,
        modifiedDate TEXT,
        invoiceId INTEGER
      )
    ''');

    // ✅ NEW: Create sales_invoice_types table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales_invoice_types (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        shortcut TEXT NOT NULL,
        maxLength INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createCustomerTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY,
        customerCode TEXT,
        customerName TEXT,
        storeName TEXT,
        storeSignage TEXT,
        customerImage TEXT,
        brgy TEXT,
        city TEXT,
        province TEXT,
        contactNumber TEXT,
        customerEmail TEXT,
        telNumber TEXT,
        bankDetails TEXT,
        customerTin TEXT,
        paymentTermId INTEGER,
        storeTypeId INTEGER,
        priceType TEXT,
        encoderId INTEGER,
        creditTypeId INTEGER,
        companyCode INTEGER,
        isActive INTEGER,
        isVAT INTEGER,
        isEWT INTEGER,
        discountTypeId INTEGER,
        otherDetails TEXT,
        classificationId INTEGER,
        latitude REAL,
        longitude REAL,
        dateEntered TEXT,
        isSynced INTEGER,
        syncedAt TEXT
      )
    ''');
  }

  static Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vos_supersales-master.db');
    await deleteDatabase(path);
    _database = null;
  }
}
