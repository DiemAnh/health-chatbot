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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                          width: 48), // Spacer to balance the right icon
                      const Text(
                        "Lịch uống thuốc",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
                    ],
                  ),
                ),

                // Mascot & text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/mascot.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Đến giờ uống thuốc rồi!\nBạn uống thuốc chưa?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadData,
                    child: _medications.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  "Bạn đã uống hết thuốc.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                                bottom:
                                    150), // Prevent overlap with bottom bar & FAB
                            itemCount: _medications.length,
                            itemBuilder: (context, i) {
                              final m = _medications[i];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/pill.png',
                                            width: 50,
                                            height: 50,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  m['name'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "7:00 AM | ${m['dosageAmount'] ?? '1'} ${m['dosageUnit'] ?? 'viên'}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF65AFE3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          child: const Text(
                                            "Xác nhận",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 90, // Above bottom bar
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Khẩn cấp action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F), // Red
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.phone_in_talk,
                    color: Colors.white, size: 24),
                label: const Text(
                  "Khẩn cấp",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
