import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/uniform_model.dart';
import '../services/firestore_service.dart';

class AddEditScreen extends StatefulWidget {
  final UniformModel? uniform;

  const AddEditScreen({super.key, this.uniform});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _empIdController;
  late TextEditingController _departmentController;
  String? _selectedSize;
  late TextEditingController _quantityController;
  bool _isLoading = false;

  final List<String> _uniformSizes = ['S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.uniform?.name ?? '');
    _empIdController = TextEditingController(text: widget.uniform?.empId ?? '');
    _departmentController = TextEditingController(text: widget.uniform?.department ?? '');
    _selectedSize = widget.uniform?.size;
    _quantityController = TextEditingController(text: widget.uniform?.quantity.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _empIdController.dispose();
    _departmentController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final firestoreService = context.read<FirestoreService>();
    final newUniform = UniformModel(
      name: _nameController.text.trim(),
      empId: _empIdController.text.trim(),
      department: _departmentController.text.trim(),
      size: _selectedSize!,
      quantity: int.parse(_quantityController.text.trim()),
    );

    try {
      if (widget.uniform == null) {
        await firestoreService.addRecord(newUniform);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record added successfully!')),
        );
      } else {
        if (widget.uniform!.id != null) {
          await firestoreService.updateRecord(widget.uniform!.id!, newUniform);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record updated successfully!')),
          );
        }
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save record: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.uniform == null ? 'Add New Record' : 'Edit Record',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Employee Name', Icons.person_outline),
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _empIdController,
                decoration: _inputDecoration('Employee ID', Icons.badge_outlined),
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _departmentController,
                decoration: _inputDecoration('Department', Icons.business_outlined),
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSize,
                decoration: _inputDecoration('Uniform Size', Icons.format_size),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                items: _uniformSizes.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(size, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSize = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: _inputDecoration('Quantity', Icons.numbers),
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: Text(
                  widget.uniform == null ? 'Add Record' : 'Update Record',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
