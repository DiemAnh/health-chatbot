import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  PlatformFile? _selectedFile;
  
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });

        if (path != null) {
          final file = File(path);
          setState(() {
            _selectedFile = PlatformFile(
              name: 'Ghi_am_${DateTime.now().millisecondsSinceEpoch}.mp3',
              size: file.lengthSync(),
              path: path,
            );
          });
        }
      } else {
        if (await _audioRecorder.hasPermission()) {
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/recorded_${DateTime.now().millisecondsSinceEpoch}.mp3';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );

          setState(() {
            _isRecording = true;
          });
        }
      }
    } catch (e) {
      print('Lỗi ghi âm: $e');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'mp3', 'wav', 'm4a', 'aac'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
    });
  }

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
    if (text.trim().isEmpty && _selectedFile == null) return;

    final fileToSend = _selectedFile;
    
 
    final bool isAudio = fileToSend != null && 
        fileToSend.extension != null && 
        ['mp3', 'wav', 'm4a', 'aac'].contains(fileToSend.extension!.toLowerCase());
        
    final String contentToSend = isAudio ? "" : text;

    setState(() {
      messages.add({
        "role": "user",
        "content": contentToSend,
        "filePath": fileToSend?.path,
        "fileName": fileToSend?.name,
        "isAudio": isAudio,
      });
      sending = true;
    });

    _controller.clear();
    _clearSelectedFile();

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
      filePath: fileToSend?.path,
      fields: {
        "conversationId": conversationId.toString(),
        "content": contentToSend,
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final data = body['data'];
      setState(() {
        messages.add({
          "role": "bot",
          "content": data['content']?.toString() ?? "",
          "filePath": data['filePath'],
          "fileType": data['fileType'],
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
    final content = msg['content']?.toString() ?? "";
    final filePath = msg['filePath'];
    final fileName = msg['fileName'];
    final fileType = msg['fileType']?.toString() ?? "";
    final isAudio = msg['isAudio'] == true || fileType.startsWith('audio');
    final isImage = fileType.startsWith('image') || (fileName != null && RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false).hasMatch(fileName));

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (filePath != null) ...[
              if (isImage) 
                const Icon(Icons.image, size: 40, color: Colors.white70)
              else if (isAudio)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.audiotrack, color: isUser ? Colors.white : Colors.black54),
                    const SizedBox(width: 8),
                    Text("Audio file", style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ],
                )
              else 
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, color: isUser ? Colors.white : Colors.black54),
                    const SizedBox(width: 8),
                    Text(fileName ?? "Attachment", style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ],
                ),
              if (content.isNotEmpty) const SizedBox(height: 8),
            ],
            if (content.isNotEmpty)
              Text(
                content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
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
              if (_selectedFile != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Icon(
                        ['mp3', 'wav', 'm4a', 'aac'].contains(_selectedFile!.extension?.toLowerCase()) 
                          ? Icons.audiotrack 
                          : Icons.image,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFile!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _clearSelectedFile,
                      ),
                    ],
                  ),
                ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: bottomInset + 80, 
                  top: 8,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.blue),
                      onPressed: _isRecording ? null : _pickFile,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          if (_isRecording)
                            Container(
                              height: 48,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Đang ghi âm...",
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          else
                            TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              onTap: () {
                                FocusScope.of(context).requestFocus(_focusNode);
                              },
                              decoration: const InputDecoration(
                                hintText: "Nhập tin nhắn...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop_circle : Icons.mic,
                        color: _isRecording ? Colors.red : Colors.blue,
                        size: _isRecording ? 32 : 24,
                      ),
                      onPressed: _toggleRecording,
                    ),
                    if (!_isRecording)
                      sending
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
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