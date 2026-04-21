import 'package:flutter/material.dart';
import '../../constants/api_constants.dart';
import '../../services/api_service.dart';

class MedicationFormScreen extends StatefulWidget {
  final Map? data;

  const MedicationFormScreen({super.key, this.data});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _api = ApiService();

  final nameCtrl = TextEditingController();
  final dosageAmountCtrl = TextEditingController();
  final dosageUnitCtrl = TextEditingController();
  final frequencyCtrl = TextEditingController();
  final totalQuantityCtrl = TextEditingController();
  final time1Ctrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final d = widget.data;
    if (d != null) {
      nameCtrl.text = d['name'] ?? '';
      dosageAmountCtrl.text = "${d['dosageAmount'] ?? ''}";
      dosageUnitCtrl.text = d['dosageUnit'] ?? '';
      frequencyCtrl.text = d['frequency'] ?? '';
      totalQuantityCtrl.text = "${d['totalQuantity'] ?? ''}";
      time1Ctrl.text = d['medicationTime1'] ?? '';
      startDateCtrl.text = d['startDate'] ?? '';
      endDateCtrl.text = d['endDate'] ?? '';
    }
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> pickDate(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      ctrl.text = formatDate(date);
    }
  }

  Future<void> submit() async {
    setState(() => _loading = true);

    final body = {
      "name": nameCtrl.text,
      "dosageAmount": int.tryParse(dosageAmountCtrl.text) ?? 0,
      "dosageUnit": dosageUnitCtrl.text,
      "frequency": frequencyCtrl.text,
      "totalQuantity": int.tryParse(totalQuantityCtrl.text) ?? 0,
      "medicationTime1": time1Ctrl.text,
      "startDate": startDateCtrl.text,
      "endDate": endDateCtrl.text,
    };

    try {
      final isEdit = widget.data != null;

      final res = isEdit
          ? await _api.put(
              ApiConstants.medicationById(widget.data!['id']),
              body: body,
              auth: true,
            )
          : await _api.post(
              ApiConstants.medications,
              body: body,
              auth: true,
            );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${res.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    dosageAmountCtrl.dispose();
    dosageUnitCtrl.dispose();
    frequencyCtrl.dispose();
    totalQuantityCtrl.dispose();
    time1Ctrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    super.dispose();
  }

  Widget dateField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      onTap: () => pickDate(ctrl),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.data != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa thuốc" : "Thêm thuốc"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên thuốc"),
            ),
            TextField(
              controller: dosageAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Liều lượng"),
            ),
            TextField(
              controller: dosageUnitCtrl,
              decoration: const InputDecoration(labelText: "Đơn vị"),
            ),
            TextField(
              controller: frequencyCtrl,
              decoration: const InputDecoration(labelText: "Tần suất"),
            ),
            TextField(
              controller: totalQuantityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số lượng"),
            ),
            TextField(
              controller: time1Ctrl,
              decoration: const InputDecoration(labelText: "Giờ uống (HH:mm)"),
            ),
            const SizedBox(height: 12),
            dateField("Ngày bắt đầu", startDateCtrl),
            const SizedBox(height: 12),
            dateField("Ngày kết thúc", endDateCtrl),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      await submit();
                      if (widget.data == null) {
                        await _api.get(ApiConstants.medications, auth: true);
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? "Cập nhật" : "Thêm mới"),
            )
          ],
        ),
      ),
    );
  }
}