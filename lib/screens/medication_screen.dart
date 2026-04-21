import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_chatbot/screens/med_manage_screen/medication_manage_screen.dart';
import '../constants/api_constants.dart';
import '../services/api_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
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
        title: const Text("Delete"),
        content: const Text("Delete this medication?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteItem(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget info(String label, dynamic value) {
    return Text("$label: ${value ?? ''}");
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_medications.isEmpty) {
      return const Center(child: Text("No medications"));
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: SafeArea(
        child: Column(
          children: [
          Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
         IconButton(
  icon: const Icon(Icons.list, color: Colors.black),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MedicationManageScreen(),
      ),
    ).then((value) {
      loadData();
    });
  },
),
          SizedBox(width: 8),
          Text(
            "Danh sách thuốc",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),


    ],
  ),
),
  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/mascot.png',
                    width: 150,
                    height: 150,
                  ),
                  Expanded(
      child: Text(
        "Đến giờ uống thuốc rồi! Bạn uống thuốc chưa?",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        softWrap: true,
      ),
    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, i) {
                  final m = _medications[i];

                  return Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Colors.transparent, 
                          ),
                        ),
                        color: Colors.white,
                        margin: EdgeInsets.fromLTRB(
                            16, 8, 16, i == _medications.length - 1 ? 60 : 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/pill.png',
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(width: 8),
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
                                    info("Liều lượng",
                                        "${m['dosageAmount']} ${m['dosageUnit']}"),
                                    info("Tần suất", m['frequency']),
                                    info("Số lượng", m['totalQuantity']),
                                    info("Ngày bắt đầu", m['startDate']),
                                    info("Ngày kết thúc", m['endDate']),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xE365AFE3),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text("Xác nhận",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
        
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
