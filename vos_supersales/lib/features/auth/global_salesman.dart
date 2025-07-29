import 'package:vos_supersales/features/sales/salesman/salesman_model.dart';

class GlobalSalesman {
  static SalesmanModel? currentSalesman;

  static void setSalesman(SalesmanModel salesman) {
    currentSalesman = salesman;
  }

  static SalesmanModel? getSalesman() {
    return currentSalesman;
  }

  static void clear() {
    currentSalesman = null;
  }
}
