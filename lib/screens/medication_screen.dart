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

  Future<void> consumeMedication(int id) async {
    final res = await _api.post(
      ApiConstants.consumeMedication(id),
      auth: true,
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${res.statusCode}")),
      );
    }
  }

  Widget info(String label, dynamic value) {
    return Text("$label: ${value ?? ''}");
  }

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (navContext) => _buildMainContent(navContext),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                         IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black),
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
                      const Text(
                        "Lịch uống thuốc",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
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
                              final remainingQty = num.tryParse(
                                      m['remainingQuantity']?.toString() ??
                                          '0') ??
                                  0;

                              final isOutOfStock = remainingQty <= 0;
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
                                                  "${m['medicationTime1'] ?? ''} | ${m['dosageAmount'] ?? '1'} ${m['dosageUnit'] ?? 'viên'}",
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
                                          onPressed: isOutOfStock
                                              ? null
                                              : () async {
                                                  await consumeMedication(
                                                      m['id']);
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isOutOfStock
                                                ? Colors.grey
                                                : const Color(0xFF65AFE3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          child: Text(
                                            isOutOfStock
                                                ? "Đã hết thuốc"
                                                : "Xác nhận",
                                            style: const TextStyle(
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
          ],
        ),
      ),
    );
  }
}
