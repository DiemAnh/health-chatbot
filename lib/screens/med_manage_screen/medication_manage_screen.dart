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
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.get(
        ApiConstants.medications,
        auth: true,
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _medications = body['data'] ?? [];
        });
      } else {
        setState(() {
          _error = "Error: ${res.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Connection error";
      });
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> deleteItem(int id) async {
    final res = await _api.delete(
      ApiConstants.deleteMedication(id),
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      loadData();
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xóa thuốc"),
        content: const Text("Bạn có chắc chắn muốn xóa thuốc này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await deleteItem(id);
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Danh sách thuốc",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => openForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65AFE3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8)
                        ),
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                        label: const Text("Thêm",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: RefreshIndicator(
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
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _medications.length,
                            itemBuilder: (context, i) {
                              final m = _medications[i];
                              final totalQty = num.tryParse(
                                      m['remainingQuantity']?.toString() ?? '0') ??
                                  0;
                              final isOutOfStock = totalQty <= 0;

                              return Card(
                                color: isOutOfStock
                                    ? const Color(0xFFBDBDBD)
                                    : Colors.white, // Grey if out of stock
                                elevation: 0,
                                margin: EdgeInsets.fromLTRB(16, 8, 16,
                                    i == _medications.length - 1 ? 24 : 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/pill.png',
                                        width: 50,
                                        height: 50,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.medical_services,
                                                size: 50,
                                                color: Colors.blueGrey),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m['name'] ?? '',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (!isOutOfStock) ...[
                                              Text(
                                                "${m['dosageAmount'] ?? ''} ${m['dosageUnit'] ?? ''} - ${m['frequency'] ?? ''}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${m['medicationTime1'] ?? ''}", // Mocked times
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Còn $totalQty viên",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ] else ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade400,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  "Đã hết thuốc",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () => openForm(data: m),
                                            icon: const Icon(Icons.edit_square,
                                                color: Colors.black87),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(height: 16),
                                          IconButton(
                                            onPressed: () =>
                                                confirmDelete(m['id']),
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.black87),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
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
          ),
          Positioned(
            bottom: 90, // Above bottom bar padding
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
    );
  }
}
