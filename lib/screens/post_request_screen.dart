import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/buy_sell_request.dart';
import '../models/buyer.dart';
import '../services/buy_sell_service.dart';
import '../widgets/safe_image.dart';

class PostRequestScreen extends StatefulWidget {
  final Buyer buyer;
  final RequestType? initialType;

  const PostRequestScreen({super.key, required this.buyer, this.initialType});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _buySellService = BuySellService();

  late RequestType _selectedType;
  String _selectedCategory = 'Food';
  String? _imagePath;
  DateTime? _expiresAt;

  final List<String> _categories = [
    'Food', 'Fashion', 'Electronics', 'Beauty', 'Home', 'Automotive', 'Sports', 'Books', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? RequestType.buy;
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final base64 = base64Encode(bytes);
        setState(() => _imagePath = 'data:image/png;base64,$base64');
      } else {
        setState(() => _imagePath = image.path);
      }
    }
  }

  void _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _expiresAt = date);
    }
  }

  void _postRequest() async {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final request = BuySellRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.buyer.id,
        userName: widget.buyer.name,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: _priceController.text.isNotEmpty ? double.tryParse(_priceController.text) : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        imagePath: _imagePath,
        expiresAt: _expiresAt,
        tags: tags,
      );

      await _buySellService.addRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedType.name.toUpperCase()} request posted successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${_selectedType.name.toUpperCase()} Request'),
        backgroundColor: _selectedType == RequestType.buy ? Colors.green : Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request Type Toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = RequestType.buy),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedType == RequestType.buy ? Colors.green : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'LOOKING TO BUY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedType == RequestType.buy ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = RequestType.sell),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedType == RequestType.sell ? Colors.orange : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'LOOKING TO SELL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedType == RequestType.sell ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SafeImage(
                      imagePath: _imagePath,
                      fallback: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          Text('Add Photo (Optional)'),
                        ],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _selectedType == RequestType.buy ? 'What are you looking for?' : 'What are you selling?',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Category and Price
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (Optional)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isNotEmpty == true && double.tryParse(v!) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. urgent, brand new, negotiable',
                ),
              ),
              const SizedBox(height: 16),

              // Expiry Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(_expiresAt == null ? 'Set expiry date (Optional)' : 'Expires: ${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectExpiryDate,
              ),
              const SizedBox(height: 24),

              // Post Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _postRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == RequestType.buy ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text('Post ${_selectedType.name.toUpperCase()} Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}