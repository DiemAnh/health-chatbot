

import 'package:flutter/material.dart';
import 'package:health_chatbot/constants/api_constants.dart';
import 'package:health_chatbot/services/api_service.dart';

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
  final totalQuantityCtrl = TextEditingController();

  final time1Ctrl = TextEditingController();
  final time2Ctrl = TextEditingController();
  final time3Ctrl = TextEditingController();

  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  int frequency = 1;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final d = widget.data;
    if (d != null) {
      nameCtrl.text = d['name'] ?? '';
      dosageAmountCtrl.text = "${d['dosageAmount'] ?? ''}";
      dosageUnitCtrl.text = d['dosageUnit'] ?? '';
      totalQuantityCtrl.text = "${d['totalQuantity'] ?? ''}";

      frequency = int.tryParse("${d['frequency'] ?? 1}") ?? 1;

      time1Ctrl.text = d['medicationTime1'] ?? '';
      time2Ctrl.text = d['medicationTime2'] ?? '';
      time3Ctrl.text = d['medicationTime3'] ?? '';

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

  Future<void> pickTime(TextEditingController ctrl) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      ctrl.text =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  String formatTime(String timeInput) {
    if (timeInput.isEmpty) return "";
    final parts = timeInput.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    }
    return timeInput;
  }

  Future<void> submit() async {
    setState(() => _loading = true);

    final body = {
      "name": nameCtrl.text,
      "dosageAmount": int.tryParse(dosageAmountCtrl.text) ?? 0,
      "dosageUnit": dosageUnitCtrl.text,
      "frequency": frequency,
      "totalQuantity": int.tryParse(totalQuantityCtrl.text) ?? 0,
      "medicationTime1": formatTime(time1Ctrl.text),
      "medicationTime2":
          frequency >= 2 ? formatTime(time2Ctrl.text) : null,
      "medicationTime3":
          frequency >= 3 ? formatTime(time3Ctrl.text) : null,
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

  Widget timeField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      onTap: () => pickTime(ctrl),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.access_time),
      ),
    );
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

            /// 🔥 DROPDOWN TẦN SUẤT
            DropdownButtonFormField<int>(
              value: frequency,
              decoration: const InputDecoration(labelText: "Tần suất"),
              items: const [
                DropdownMenuItem(value: 1, child: Text("1 lần/ngày")),
                DropdownMenuItem(value: 2, child: Text("2 lần/ngày")),
                DropdownMenuItem(value: 3, child: Text("3 lần/ngày")),
              ],
              onChanged: (val) {
                setState(() {
                  frequency = val ?? 1;

                  /// clear field khi giảm
                  if (frequency < 3) time3Ctrl.clear();
                  if (frequency < 2) time2Ctrl.clear();
                });
              },
            ),

            TextField(
              controller: totalQuantityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số lượng"),
            ),

            const SizedBox(height: 12),

            /// 🔥 TIME DYNAMIC
            timeField("Giờ uống 1", time1Ctrl),

            if (frequency >= 2)
              timeField("Giờ uống 2", time2Ctrl),

            if (frequency >= 3)
              timeField("Giờ uống 3", time3Ctrl),

            const SizedBox(height: 12),


            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loading ? null : submit,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? "Cập nhật" : "Thêm mới"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    dosageAmountCtrl.dispose();
    dosageUnitCtrl.dispose();
    totalQuantityCtrl.dispose();
    time1Ctrl.dispose();
    time2Ctrl.dispose();
    time3Ctrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    super.dispose();
  }
}

