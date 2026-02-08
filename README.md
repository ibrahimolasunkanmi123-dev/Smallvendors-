# Small Vendors Marketplace

A Flutter app for small businesses to create digital catalogs and manage their products.

## Features

### For Vendors
- **Product Management**: Add, edit, and manage product inventory with low stock alerts
- **Digital Catalog**: Share product catalog via WhatsApp and QR codes
- **Business Profile**: Manage business information with easy editing
- **Analytics Dashboard**: View revenue charts, top products, and order statistics
- **Main Dashboard**: Comprehensive navigation with bottom tabs
- **Order Management**: Track and manage orders with status updates
- **Settings**: Dark/light theme, notifications, and data management

### For Buyers
- **Public Marketplace**: Browse products without signup required
- **Search & Filter**: Find products by category or search terms
- **Product Details**: View detailed product information in modal
- **Shopping Cart**: Add products to cart for easy ordering
- **User Profile**: Manage personal information
- **Smart Login**: Only prompted to sign up when interacting with products

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Dependencies
- `shared_preferences`: Local data storage
- `url_launcher`: Launch external URLs
- `qr_flutter`: QR code generation
- `image_picker`: Image selection
- `provider`: State management
- `package_info_plus`: App information

## Project Structure

```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic and data services
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## Key Components

### Models
- `Vendor`: Business/seller information
- `Product`: Product details and inventory
- `Buyer`: Customer information
- `Order`: Order management
- `Chat`: Messaging system

### Services
- `StorageService`: Local data persistence with session management
- `CartService`: Shopping cart management
- `ChatService`: Messaging functionality
- `ThemeService`: App theming with persistence
- `NotificationService`: Enhanced user feedback system
- `SampleDataService`: Demo data initialization

### Screens
- `PublicMarketplaceScreen`: Public product browsing without login
- `MainDashboard`: Vendor interface with bottom navigation
- `HomeScreen`: Vendor home with quick stats and actions
- `AnalyticsScreen`: Business insights with charts and metrics
- `BuyerDashboard`: Customer interface with cart badge
- `SplashScreen`: Smart routing based on login state
- `SettingsScreen`: Comprehensive app settings

## Usage

1. **Vendor Registration**: Create a vendor account with business details
2. **Add Products**: Upload product images, descriptions, and pricing
3. **Share Catalog**: Generate shareable links for WhatsApp marketing
4. **Manage Orders**: Track customer orders and communications
5. **Customer Interaction**: Chat with customers and process payments

## Testing

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.