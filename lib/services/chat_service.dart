import 'dart:convert';
import '../models/chat.dart';
import '../models/chat_message.dart';
import 'storage_service.dart';

class ChatService {
  final _storage = StorageService();
  static const String _chatsKey = 'chats';
  static const String _messagesKey = 'messages';

  Future<List<Chat>> getChats(String vendorId) async {
    final chatsData = await _storage.getData(_chatsKey) ?? '[]';
    final chatsList = jsonDecode(chatsData) as List;
    return chatsList
        .map((json) => Chat.fromJson(json))
        .where((chat) => chat.vendorId == vendorId)
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  Future<List<Chat>> getChatsForCustomer(String customerId) async {
    final chatsData = await _storage.getData(_chatsKey) ?? '[]';
    final chatsList = jsonDecode(chatsData) as List;
    return chatsList
        .map((json) => Chat.fromJson(json))
        .where((chat) => chat.customerId == customerId)
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  Future<void> saveChat(Chat chat) async {
    final chats = await getChats(chat.vendorId);
    final existingIndex = chats.indexWhere((c) => c.id == chat.id);
    
    if (existingIndex >= 0) {
      chats[existingIndex] = chat;
    } else {
      chats.add(chat);
    }
    
    await _storage.saveData(_chatsKey, jsonEncode(chats.map((c) => c.toJson()).toList()));
  }

  Future<List<ChatMessage>> getMessages(String chatId) async {
    final messagesData = await _storage.getData(_messagesKey) ?? '[]';
    final messagesList = jsonDecode(messagesData) as List;
    return messagesList
        .map((json) => ChatMessage.fromJson(json))
        .where((message) => message.chatId == chatId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> sendMessage(ChatMessage message) async {
    final messages = await _getAllMessages();
    messages.add(message);
    await _storage.saveData(_messagesKey, jsonEncode(messages.map((m) => m.toJson()).toList()));
    
    // Update chat with last message
    final chats = await getChats(message.senderId);
    final chatIndex = chats.indexWhere((c) => c.id == message.chatId);
    if (chatIndex >= 0) {
      final updatedChat = chats[chatIndex].copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
      );
      await saveChat(updatedChat);
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _getAllMessages();
    bool hasChanges = false;
    
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].chatId == chatId && 
          messages[i].senderId != userId && 
          !messages[i].isRead) {
        messages[i] = messages[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await _storage.saveData(_messagesKey, jsonEncode(messages.map((m) => m.toJson()).toList()));
    }
  }

  Future<Chat?> findOrCreateChat(String vendorId, String customerId, String customerName, String? customerPhone, {String vendorName = 'Vendor'}) async {
    final chats = await getChats(vendorId);
    final existingChat = chats.where((c) => c.customerId == customerId).firstOrNull;
    
    if (existingChat != null) {
      return existingChat;
    }
    
    final newChat = Chat(
      vendorId: vendorId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      vendorName: vendorName,
    );
    
    await saveChat(newChat);
    return newChat;
  }

  Future<void> updateMessage(ChatMessage message) async {
    final messages = await _getAllMessages();
    final index = messages.indexWhere((m) => m.id == message.id);
    
    if (index >= 0) {
      messages[index] = message;
      await _storage.saveData(_messagesKey, jsonEncode(messages.map((m) => m.toJson()).toList()));
    }
  }

  Future<List<ChatMessage>> _getAllMessages() async {
    final messagesData = await _storage.getData(_messagesKey) ?? '[]';
    final messagesList = jsonDecode(messagesData) as List;
    return messagesList.map((json) => ChatMessage.fromJson(json)).toList();
  }
}