import 'package:flutter/material.dart';
import 'package:health_chatbot/constants/api_constants.dart';
import 'package:health_chatbot/services/api_service.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final Map initialData;
  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _api = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  
  DateTime? _selectedDate;
  String? _selectedSex;
  String? _selectedBloodGroup;
  bool isSaving = false;

  final List<String> _sexOptions = ['Nam', 'Nữ', 'Khác'];
  final List<String> _bloodGroups = ['A', 'B', 'AB', 'O', 'Chưa rõ'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['fullName']);
    _emailController = TextEditingController(text: widget.initialData['email']);
    _heightController = TextEditingController(text: widget.initialData['height']?.toString() ?? '0');
    _weightController = TextEditingController(text: widget.initialData['weight']?.toString() ?? '0');
    
    _selectedSex = widget.initialData['sex'];
    _selectedBloodGroup = widget.initialData['bloodGroup'];
    if (widget.initialData['dateOfBirth'] != null) {
      _selectedDate = DateTime.tryParse(widget.initialData['dateOfBirth']);
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    
    final Map<String, dynamic> body = {
      "fullName": _nameController.text,
      "email": _emailController.text,
      "dateOfBirth": _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      "sex": _selectedSex,
      "height": double.tryParse(_heightController.text) ?? 0,
      "weight": double.tryParse(_weightController.text) ?? 0,
      "bloodGroup": _selectedBloodGroup,
    };

    final res = await _api.put(
      ApiConstants.updateProfile,
      auth: true,
      body: body,
    );

    if (res.statusCode == 200) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi cập nhật profile")),
      );
    }
    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa hồ sơ sức khỏe")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              title: Text(_selectedDate == null ? "Chọn ngày sinh" : "Ngày sinh: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}"),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _sexOptions.contains(_selectedSex) ? _selectedSex : null,
              decoration: const InputDecoration(labelText: "Giới tính", border: OutlineInputBorder()),
              items: _sexOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSex = val),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Chiều cao (cm)", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Cân nặng (kg)", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _bloodGroups.contains(_selectedBloodGroup) ? _selectedBloodGroup : null,
              decoration: const InputDecoration(labelText: "Nhóm máu", border: OutlineInputBorder()),
              items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _selectedBloodGroup = val),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("LƯU THÔNG TIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}