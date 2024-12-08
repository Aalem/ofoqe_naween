import 'package:ofoqe_naween/values/collection_fields/currencies_fields.dart';

class Currency {
  final String id;
  final String name;
  final String symbol;

  Currency({required this.name, required this.symbol, required this.id});

  factory Currency.fromMap(Map<String, dynamic> map, String id) {
    return Currency(
      id: map[CurrencyFields.id] ?? '',
      name: map[CurrencyFields.name] ?? '',
      symbol: map[CurrencyFields.symbol] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CurrencyFields.id: id,
      CurrencyFields.name: name,
      CurrencyFields.symbol: symbol,
    };
  }
}
