import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../models/chat.dart';
import '../models/vendor.dart';
import '../models/customer.dart';
import '../services/chat_service.dart';
import 'buyer_chat_screen.dart';

class BuyerChatListScreen extends StatefulWidget {
  final Buyer? buyer;

  const BuyerChatListScreen({super.key, this.buyer});

  @override
  State<BuyerChatListScreen> createState() => _BuyerChatListScreenState();
}

class _BuyerChatListScreenState extends State<BuyerChatListScreen> {
  final _chatService = ChatService();
  List<Chat> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    if (widget.buyer != null) {
      final chats = await _chatService.getChatsForCustomer(widget.buyer!.id);
      setState(() {
        _chats = chats;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Vendor _getVendorFromChat(Chat chat) {
    return Vendor(
      id: chat.vendorId,
      ownerName: chat.vendorName,
      businessName: chat.vendorName,
      phone: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with vendors',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      chat.vendorName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(chat.vendorName),
                  subtitle: Text(
                    chat.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: chat.unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        )
                      : null,
                  onTap: () {
                    final customer = Customer(
                      id: widget.buyer!.id,
                      name: widget.buyer!.name,
                      phone: widget.buyer!.phone,
                      email: widget.buyer!.email,
                      address: widget.buyer!.address,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyerChatScreen(
                          customer: customer,
                          vendor: _getVendorFromChat(chat),
                          existingChat: chat,
                        ),
                      ),
                    ).then((_) => _loadChats());
                  },
                );
              },
            ),
    );
  }
}
