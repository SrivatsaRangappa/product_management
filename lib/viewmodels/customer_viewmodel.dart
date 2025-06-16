
import 'package:flutter/material.dart';
import 'package:product_mgmt_app/models/customer_model.dart';
import 'package:product_mgmt_app/services/api_service.dart';
import 'package:product_mgmt_app/viewmodels/product_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerViewModel extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  bool _isLoading = true;
  String? _selectedCustomerId;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get selectedCustomerId => _selectedCustomerId;

  Future<void> fetchCustomers(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? warehouseId = prefs.getString('warehouseId');
      String? token = prefs.getString('token');

      if (warehouseId == null || token == null) {
       
        _isLoading = false;
        notifyListeners();
        return;
      }

      ApiService _apiService = ApiService();
      var response = await _apiService.get(
        'https://business.city-link.co.in/testingstorage/customer/warehouse/$warehouseId',
      );

      if (response != null &&
          response['status'] == true &&
          response['result'] is List) {
        _customers = (response['result'] as List)
            .map((json) => CustomerModel.fromJson(json))
            .toList();

        if (_customers.isNotEmpty) {
          _selectedCustomerId = _customers.first.id.toString();
          await prefs.setString('customerId', _selectedCustomerId!);

           
          await selectCustomer(_selectedCustomerId!, context, autoSelect: true);
        }
      } else {
        _customers = [];
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error fetching customers"),
        ),
      );
     
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCustomer(String customerId, BuildContext context,
      {bool autoSelect = false}) async {
    _selectedCustomerId = customerId;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('customerId', customerId);

    final productViewModel =
        Provider.of<ProductViewModel>(context, listen: false);

    productViewModel.clearStocks();
    await productViewModel.fetchStocks(customerId);
  }
}
