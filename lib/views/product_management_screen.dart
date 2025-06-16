
import 'package:flutter/material.dart';
import 'package:product_mgmt_app/views/product_detail_screen.dart';
import 'package:product_mgmt_app/widgets/appbar.dart';
import 'package:provider/provider.dart';
import 'package:product_mgmt_app/viewmodels/product_viewmodel.dart';
import 'package:product_mgmt_app/viewmodels/customer_viewmodel.dart';
import 'package:intl/intl.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  String? selectedCustomerId;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerViewModel =
          Provider.of<CustomerViewModel>(context, listen: false);
      await customerViewModel.fetchCustomers(context);

      if (customerViewModel.customers.isNotEmpty) {
        selectedCustomerId = customerViewModel.customers.first.id.toString();
        customerViewModel.selectCustomer(selectedCustomerId!, context);

        Provider.of<ProductViewModel>(context, listen: false)
            .fetchStocks(selectedCustomerId!);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final productViewModel =
        Provider.of<ProductViewModel>(context, listen: false);
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 50) {
      if (selectedCustomerId != null &&
          productViewModel.hasMore &&
          !productViewModel.isLoadingStocks) {
        productViewModel.loadMoreStocks(selectedCustomerId!);
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: const DefaultAppBar(title: "      Product Management", showBackButton:false),
      body: _buildBody(), 
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

 
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildProductManagement();
      case 1:
        return _buildSettingsPage();
      case 2:
        return _buildAccountPage();
      default:
        return _buildProductManagement();
    }
  }

 
  Widget _buildProductManagement() {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final customerViewModel = Provider.of<CustomerViewModel>(context);

    return customerViewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: customerViewModel.selectedCustomerId,
                      isExpanded: true,
                      onChanged: (newCustomerId) {
                        if (newCustomerId != null) {
                          setState(() {
                            selectedCustomerId = newCustomerId;
                          });
                          customerViewModel.selectCustomer(
                              newCustomerId, context);
                          Provider.of<ProductViewModel>(context, listen: false)
                              .fetchStocks(newCustomerId);
                          searchController.clear();
                        }
                      },
                      items: customerViewModel.customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer.id.toString(),
                          child: Text(customer.name),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 50,
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text:
                                DateFormat('yyyy-MM-dd').format(selectedDate)),
                        decoration: InputDecoration(
                          labelText: "Select Date",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today_rounded,
                                color: Colors.purple.shade900, size: 16),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != selectedDate) {
                                setState(() => selectedDate = picked);
                                Provider.of<ProductViewModel>(context,
                                        listen: false)
                                    .updateSelectedDate(
                                        DateFormat('yyyy-MM-dd')
                                            .format(selectedDate),
                                        selectedCustomerId!);
                                searchController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            labelText: "Search Product",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (query) {
                            Provider.of<ProductViewModel>(context,
                                    listen: false)
                                .searchStocks(query);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: productViewModel.stocks.length +
                        (productViewModel.hasMore &&
                                !searchController.text.isNotEmpty
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index < productViewModel.stocks.length) {
                        final stock = productViewModel.stocks[index];
                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen(product: stock),
                                ),
                              );
                            },
                            title: Text(stock.productId),
                            subtitle: Text(stock.productName),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
            ],
          );
  }

  
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: "Products"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
      ],
    );
  }

 
  Widget _buildSettingsPage() {
    return const Center(child: Text("⚙️ Settings Page"));
  }

 
  Widget _buildAccountPage() {
    return const Center(child: Text("👤 Account Page"));
  }
}
