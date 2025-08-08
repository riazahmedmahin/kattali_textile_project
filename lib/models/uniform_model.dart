import 'package:cloud_firestore/cloud_firestore.dart';

class UniformModel {
  final String? id;
  final String name;
  final String empId;
  final String department;
  final String size;
  final int quantity;

  UniformModel({
    this.id,
    required this.name,
    required this.empId,
    required this.department,
    required this.size,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'empId': empId,
      'department': department,
      'size': size,
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory UniformModel.fromMap(Map<String, dynamic> map, String id) {
    return UniformModel(
      id: id,
      name: map['name'] ?? '',
      empId: map['empId'] ?? '',
      department: map['department'] ?? '',
      size: map['size'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}
