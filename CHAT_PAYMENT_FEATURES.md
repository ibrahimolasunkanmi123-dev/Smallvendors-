# Chat and Payment Features

## Overview
The app now includes integrated chat and payment functionality allowing sellers and buyers to communicate and process payments directly within the chat interface.

## Features

### 1. Chat System
- **Real-time messaging** between sellers and buyers
- **Product sharing** - Sellers can share product details in chat
- **Message history** - All conversations are saved locally
- **Unread indicators** - Shows unread message counts

### 2. Payment Integration
- **Payment Requests** - Sellers can request specific amounts from buyers
- **In-Chat Payments** - Buyers can pay directly from the chat interface
- **Multiple Payment Methods**:
  - Cash
  - Card
  - Mobile Payment
  - Bank Transfer
- **Payment Confirmation** - Automatic confirmation messages after payment
- **Transaction History** - All payments are recorded as transactions

## How to Use

### For Sellers:

1. **Access Chat**
   - Navigate to the Chat List from the main dashboard
   - Select a customer to start chatting

2. **Send Messages**
   - Type your message and tap Send
   - Use the + button to share products

3. **Request Payment**
   - Tap the Request Payment icon (📄) in the app bar
   - Enter the amount and optional description
   - Tap Send to create a payment request

4. **Process Payments**
   - When buyer clicks "Pay Now", select payment method
   - Payment is automatically recorded as a transaction

### For Buyers:

1. **View Payment Requests**
   - Payment requests appear as green cards in chat
   - Shows amount and description

2. **Make Payment**
   - Tap "Pay Now" on the payment request
   - Select payment method (Cash/Card/Mobile)
   - Payment is confirmed automatically

## Technical Details

### Models
- **ChatMessage**: Extended with payment fields (amount, paymentStatus)
- **Transaction**: Updated to support chat-based payments
- **MessageType**: Added `payment` and `paymentRequest` types

### Services
- **ChatService**: Handles message storage and retrieval
- **TransactionService**: Records all payment transactions

### Storage
- All data stored locally using SharedPreferences
- Chat messages and transactions persist across app sessions
