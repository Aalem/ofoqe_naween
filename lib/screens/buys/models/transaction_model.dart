
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String jalaliDate;
  final DateTime gregorianDate;
  final DateTime date;
  final String description;
  final double debit;
  final double credit;

  TransactionModel({
    required this.id,
    required this.jalaliDate,
    required this.gregorianDate,
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      jalaliDate: data['jalali_date'],
      gregorianDate: (data['gregorian_date'] as Timestamp).toDate(),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'],
      debit: data['debit'].toDouble(),
      credit: data['credit'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jalali_date': jalaliDate,
      'gregorian_date': gregorianDate,
      'date': date,
      'description': description,
      'debit': debit,
      'credit': credit,
    };
  }
}
