import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  int? conversationId;
  List<Map<String, dynamic>> messages = [];
  bool sending = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  Future<int?> createConversation() async {
    final res = await _api.postMultipart(
      ApiConstants.createConversation,
      auth: true,
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['data']['id'];
    }
    return null;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "content": text,
      });
      sending = true;
    });

    _controller.clear();

    if (conversationId == null) {
      conversationId = await createConversation();
      if (conversationId == null) {
        setState(() => sending = false);
        return;
      }
    }

    final res = await _api.postMultipart(
      ApiConstants.sendMessage,
      auth: true,
      fields: {
        "conversationId": conversationId.toString(),
        "content": text,
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() {
        messages.add({
          "role": "bot",
          "content": body['data']['content'].toString(),
        });
      });
    }

    setState(() => sending = false);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> deleteConversation() async {
    if (conversationId == null) return;

    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa cuộc trò chuyện"),
        content: const Text("Bạn có chắc muốn xóa không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await _api.delete(
      ApiConstants.deleteConversation(conversationId!),
      auth: true,
    );

    if (res.statusCode == 200) {
      setState(() {
        messages.clear();
        conversationId = null;
      });
      _focusNode.requestFocus();
    }
  }

  Widget bubble(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['content'].toString(),
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bắt đầu trò chuyện"),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: sending ? null : deleteConversation,
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            "Hãy nhập câu hỏi để bắt đầu trò chuyện với chatbot của bạn",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return bubble(messages[index]);
                        },
                      ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: bottomInset + 80,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        onTap: () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed: () => sendMessage(_controller.text),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}