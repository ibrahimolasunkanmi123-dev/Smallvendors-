import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/customer.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class BuyerChatScreen extends StatefulWidget {
  final Customer customer;
  final Vendor vendor;
  final Chat? existingChat;

  const BuyerChatScreen({
    super.key,
    required this.customer,
    required this.vendor,
    this.existingChat,
  });

  @override
  State<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends State<BuyerChatScreen> {
  final _chatService = ChatService();
  final _storage = StorageService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  List<Product> _products = [];
  late Chat _chat;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _loadProducts();
  }

  void _initializeChat() async {
    if (widget.existingChat != null) {
      _chat = widget.existingChat!;
    } else {
      _chat = Chat(
        vendorId: widget.vendor.id,
        customerId: widget.customer.id,
        customerName: widget.customer.name,
        customerPhone: widget.customer.phone,
      );
    }
    _loadMessages();
  }

  void _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(_chat.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loadProducts() async {
    try {
      final products = await _storage.getProducts();
      if (mounted) {
        setState(() {
          _products = products.where((p) => p.vendorId == widget.vendor.id).toList();
        });
      }
    } catch (e) {
      // Handle silently
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = ChatMessage(
      chatId: _chat.id,
      senderId: widget.customer.id,
      senderName: widget.customer.name,
      content: content,
    );

    _messageController.clear();
    
    try {
      await _chatService.sendMessage(message);
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showProductCatalog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Catalog', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('No products available'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shopping_bag),
                            ),
                            title: Text(product.name),
                            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () {
                                Navigator.pop(context);
                                _inquireAboutProduct(product);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _inquireAboutProduct(Product product) async {
    final message = ChatMessage(
      chatId: _chat.id,
      senderId: widget.customer.id,
      senderName: widget.customer.name,
      content: 'I\'m interested in ${product.name} - \$${product.price.toStringAsFixed(2)}',
      type: MessageType.product,
      productId: product.id,
    );

    try {
      await _chatService.sendMessage(message);
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send inquiry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.vendor.businessName),
            Text(
              'Chat with seller',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: _showProductCatalog,
            tooltip: 'View Products',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('Start a conversation with the seller'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isCustomer = message.senderId == widget.customer.id;
                          
                          return Align(
                            alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: message.type == MessageType.paymentRequest
                                    ? Colors.orange[100]
                                    : message.type == MessageType.payment
                                        ? Colors.green[100]
                                        : isCustomer 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message.type == MessageType.product)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.shopping_bag, size: 16, color: isCustomer ? Colors.white : Colors.black),
                                          const SizedBox(width: 8),
                                          Text('Product Inquiry', style: TextStyle(color: isCustomer ? Colors.white : Colors.black, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  if (message.type == MessageType.paymentRequest)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.payment, size: 16, color: Colors.orange),
                                            const SizedBox(width: 8),
                                            const Text('Payment Request', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Amount: \$${message.amount!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        if (message.content.isNotEmpty) Text(message.content),
                                      ],
                                    ),
                                  if (message.type == MessageType.payment)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                            const SizedBox(width: 8),
                                            const Text('Payment Completed', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(message.content),
                                      ],
                                    ),
                                  if (message.type == MessageType.text)
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isCustomer ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: message.type == MessageType.paymentRequest || message.type == MessageType.payment
                                          ? Colors.grey[600]
                                          : isCustomer ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}