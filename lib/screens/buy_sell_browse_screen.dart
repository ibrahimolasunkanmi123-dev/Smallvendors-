import 'package:flutter/material.dart';
import '../models/buy_sell_request.dart';
import '../models/buyer.dart';
import '../services/buy_sell_service.dart';
import '../widgets/safe_image.dart';
import 'post_request_screen.dart';

class BuySellBrowseScreen extends StatefulWidget {
  final Buyer buyer;

  const BuySellBrowseScreen({super.key, required this.buyer});

  @override
  State<BuySellBrowseScreen> createState() => _BuySellBrowseScreenState();
}

class _BuySellBrowseScreenState extends State<BuySellBrowseScreen> with SingleTickerProviderStateMixin {
  final _buySellService = BuySellService();
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  List<BuySellRequest> _buyRequests = [];
  List<BuySellRequest> _sellRequests = [];
  List<BuySellRequest> _filteredBuyRequests = [];
  List<BuySellRequest> _filteredSellRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  void _loadRequests() async {
    final buyRequests = await _buySellService.getRequestsByType(RequestType.buy);
    final sellRequests = await _buySellService.getRequestsByType(RequestType.sell);
    
    setState(() {
      _buyRequests = buyRequests;
      _sellRequests = sellRequests;
      _filteredBuyRequests = buyRequests;
      _filteredSellRequests = sellRequests;
      _loading = false;
    });
  }

  void _searchRequests(String query) {
    setState(() {
      _filteredBuyRequests = _buyRequests.where((r) =>
        r.title.toLowerCase().contains(query.toLowerCase()) ||
        r.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      _filteredSellRequests = _sellRequests.where((r) =>
        r.title.toLowerCase().contains(query.toLowerCase()) ||
        r.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Widget _buildRequestCard(BuySellRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: request.type == RequestType.buy ? Colors.green : Colors.orange,
                  child: Text(request.userName[0], style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(request.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (request.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('\$${request.price!.toStringAsFixed(2)}', 
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (request.imagePath != null)
              Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SafeImage(
                    imagePath: request.imagePath!,
                    fallback: Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(request.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(request.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                if (request.location != null) ...[
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  Text(request.location!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                Text(_formatDate(request.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            if (request.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: request.tags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy & Sell'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Looking to Buy (${_filteredBuyRequests.length})'),
            Tab(text: 'Looking to Sell (${_filteredSellRequests.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchRequests,
              decoration: InputDecoration(
                hintText: 'Search requests...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Buy Requests
                      _filteredBuyRequests.isEmpty
                          ? const Center(child: Text('No buy requests found'))
                          : ListView.builder(
                              itemCount: _filteredBuyRequests.length,
                              itemBuilder: (context, index) => _buildRequestCard(_filteredBuyRequests[index]),
                            ),
                      // Sell Requests
                      _filteredSellRequests.isEmpty
                          ? const Center(child: Text('No sell requests found'))
                          : ListView.builder(
                              itemCount: _filteredSellRequests.length,
                              itemBuilder: (context, index) => _buildRequestCard(_filteredSellRequests[index]),
                            ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostRequestScreen(buyer: widget.buyer)),
          );
          _loadRequests(); // Refresh after posting
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Request'),
      ),
    );
  }
}