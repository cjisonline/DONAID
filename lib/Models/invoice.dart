import 'package:donaid/Models/DonaidInfo.dart';
import 'DonorUser.dart';

class Invoice {
  final InvoiceInfo info;
  final DonaidInfo supplier;
  final DonorUser customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
  });
}

class InvoiceItem {
  final String title;
  final DateTime date;
  final String organization;
  final String type;
  final double price;

  const InvoiceItem({
    required this.title,
    required this.date,
    required this.organization,
    required this.type,
    required this.price,
  });
}