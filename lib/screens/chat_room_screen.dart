import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../models/vendor.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final Buyer? buyer;
  final Vendor? vendor;

  const ChatRoomScreen({super.key, this.buyer, this.vendor});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  List<Chat> _chats = [];
  Chat? _selectedChat;
  List<ChatMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    try {
      List<Chat> chats;
      if (widget.buyer != null) {
        chats = await _chatService.getChatsForCustomer(widget.buyer!.id);
      } else {
        chats = await _chatService.getChats(widget.vendor!.id);
      }
      setState(() {
        _chats = chats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _selectChat(Chat chat) async {
    setState(() => _selectedChat = chat);
    final messages = await _chatService.getMessages(chat.id);
    setState(() => _messages = messages);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedChat == null) return;

    final message = ChatMessage(
      chatId: _selectedChat!.id,
      senderId: widget.buyer?.id ?? widget.vendor!.id,
      senderName: widget.buyer?.name ?? widget.vendor!.businessName,
      content: _messageController.text.trim(),
    );

    _messageController.clear();
    await _chatService.sendMessage(message);
    _selectChat(_selectedChat!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buyer != null ? 'Chat with Vendors' : 'Customer Chats'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Chat List
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: _chats.isEmpty
                      ? const Center(child: Text('No chats yet'))
                      : ListView.builder(
                          itemCount: _chats.length,
                          itemBuilder: (context, index) {
                            final chat = _chats[index];
                            return ListTile(
                              selected: _selectedChat?.id == chat.id,
                              leading: CircleAvatar(
                                child: Text(
                                  widget.buyer != null
                                      ? chat.vendorName[0]
                                      : chat.customerName[0],
                                ),
                              ),
                              title: Text(
                                widget.buyer != null
                                    ? chat.vendorName
                                    : chat.customerName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                chat.lastMessage ?? 'No messages',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectChat(chat),
                            );
                          },
                        ),
                ),
                // Chat Messages
                Expanded(
                  child: _selectedChat == null
                      ? const Center(child: Text('Select a chat to start messaging'))
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Text(
                                      widget.buyer != null
                                          ? _selectedChat!.vendorName[0]
                                          : _selectedChat!.customerName[0],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.buyer != null
                                        ? _selectedChat!.vendorName
                                        : _selectedChat!.customerName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  final isMe = message.senderId == (widget.buyer?.id ?? widget.vendor!.id);
                                  return Align(
                                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.all(12),
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.blue : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.content,
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        hintText: 'Type a message...',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _sendMessage,
                                    icon: const Icon(Icons.send),
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}