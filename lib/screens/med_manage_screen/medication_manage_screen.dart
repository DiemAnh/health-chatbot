import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_chatbot/constants/api_constants.dart';
import 'package:health_chatbot/screens/med_manage_screen/medication_form_screen.dart';
import 'package:health_chatbot/services/api_service.dart';

class MedicationManageScreen extends StatefulWidget {
  const MedicationManageScreen({super.key});

  @override
  State<MedicationManageScreen> createState() => _MedicationManageScreenState();
}

class _MedicationManageScreenState extends State<MedicationManageScreen> {
  final _api = ApiService();
  bool _loading = false;
  String? _error;
  List<dynamic> _medications = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.get(
        ApiConstants.medications,
        auth: true,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _medications = body['data'] ?? [];
        });
      } else {
        _error = "Error: ${res.statusCode}";
      }
    } catch (e) {
      _error = "Connection error";
    }

    setState(() => _loading = false);
  }

  Future<void> deleteItem(int id) async {
    final res = await _api.delete(
      ApiConstants.deleteMedication(id),
    );

    if (res.statusCode == 200) {
      loadData();
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa thuốc"),
        content: const Text("Bạn có chắc chắn muốn xóa thuốc này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteItem(id);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void openForm({Map? data}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicationFormScreen(data: data),
      ),
    ).then((_) => loadData());
  }

  Widget info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text("$label: ${value ?? ''}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý thuốc"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => openForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xE365AFE3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text("Thêm", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: _error != null
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Center(child: Text(_error!)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: _medications.length,
                itemBuilder: (context, i) {
                  final m = _medications[i];

                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    margin: EdgeInsets.fromLTRB(16, 8, 16, i == _medications.length - 1 ? 24 : 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/pill.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.medical_services, size: 60, color: Colors.blueGrey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                info("Liều lượng", "${m['dosageAmount']} ${m['dosageUnit']}"),
                                info("Tần suất", m['frequency']),
                                info("Số lượng", m['totalQuantity']),
                                info("Ngày bắt đầu", m['startDate']),
                                info("Ngày kết thúc", m['endDate']),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => confirmDelete(m['id']),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      label: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => openForm(data: m),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xE365AFE3),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                                      label: const Text("Sửa", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}