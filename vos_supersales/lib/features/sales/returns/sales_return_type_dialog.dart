import 'package:flutter/material.dart';
import 'sales_return_type_service.dart';
import 'sales_return_type_model.dart';

Future<SalesReturnType?> showSalesReturnTypeDialog(BuildContext context) async {
  final service = SalesReturnTypeService();
  List<SalesReturnType> returnTypes = [];

  try {
    returnTypes = await service.fetchReturnTypes();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load return types')));
    return null;
  }

  return await showDialog<SalesReturnType>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Select Return Type'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: returnTypes.length,
          itemBuilder: (context, index) {
            final type = returnTypes[index];
            return ListTile(
              title: Text(type.typeName),
              subtitle: Text(type.description),
              onTap: () => Navigator.of(context).pop(type),
            );
          },
        ),
      ),
    ),
  );
}
