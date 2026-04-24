import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_chatbot/constants/api_constants.dart';
import 'package:health_chatbot/services/api_service.dart';

class ConversationDrawer extends StatefulWidget {
  final Function(int id) onSelect;
  final Function() onCreateNew;

  const ConversationDrawer({
    super.key,
    required this.onSelect,
    required this.onCreateNew,
  });

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  final _api = ApiService();
  List<dynamic> conversations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    final res = await _api.get(
      ApiConstants.listConversation,
      auth: true,
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() {
        conversations = body['data'] ?? [];
        loading = false;
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm cuộc trò chuyện",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Cuộc trò chuyện mới"),
            onTap: widget.onCreateNew,
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Cuộc trò chuyện",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, i) {
                      final c = conversations[i];

                      return ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(
                          c['title'] ?? 'Không có tiêu đề',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => widget.onSelect(c['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

}