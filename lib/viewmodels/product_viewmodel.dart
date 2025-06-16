

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/stock_model.dart';

class ProductViewModel extends ChangeNotifier {
  List<StockModel> _stocks = [];
  List<StockModel> _filteredStocks = [];  
  bool _isLoadingStocks = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _selectedDate =
      DateTime.now().toIso8601String().split('T')[0];  

  List<StockModel> get stocks =>
      _filteredStocks.isNotEmpty ? _filteredStocks : _stocks;
  bool get isLoadingStocks => _isLoadingStocks;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String get selectedDate => _selectedDate;  

  void clearStocks() {
    _stocks.clear();
    _filteredStocks.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingStocks = false;
    notifyListeners();
  }

 
  void updateSelectedDate(String newDate, String customerId) {
    _selectedDate = newDate;

    clearStocks();
    fetchStocks(customerId);
  }
  
  Future<void> fetchStocks(String customerId, {int page = 1}) async {
    if (_isLoadingStocks || !_hasMore) return;

    try {
      _isLoadingStocks = true;
      notifyListeners();

      ApiService _apiService = ApiService();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? warehouseId = prefs.getString('warehouseId');
      String? token = prefs.getString('token');

      if (warehouseId == null || token == null) {
        _isLoadingStocks = false;
      
        return;
      }

   

      var requestBody = {
        "pageNumber": page,
        "pageLimit": 10,
      };

      var response = await _apiService.post(
        'https://business.city-link.co.in/testingstorage/stock/statement/date/$_selectedDate/warehouse/$warehouseId/customer/$customerId',
        requestBody,
      );
     
      if (response != null &&
          response['status'] == true &&
          response['result'] is List) {
        List<StockModel> fetchedStocks = (response['result'] as List)
            .map((json) => StockModel.fromJson(json))
            .toList();

        if (page == 1) {
          _stocks = fetchedStocks;
        } else {
          _stocks.addAll(fetchedStocks);
        }

        _filteredStocks = _stocks;  
        _hasMore = fetchedStocks.length == 10;
        if (fetchedStocks.isNotEmpty) {
          _currentPage = page;
        }

      
      } else {
        _hasMore = false;
     
      }
    } catch (e) {
     
     
      print(" Error fetching stock statement: $e");
    } finally {
      _isLoadingStocks = false;
      notifyListeners();
    }
  }

  
  Future<void> loadMoreStocks(String customerId) async {
    if (!_hasMore || _isLoadingStocks) return;

    int nextPage = _currentPage + 1;
    await fetchStocks(customerId, page: nextPage);
  }

  
  void searchStocks(String query) {
    if (query.isEmpty) {
      _filteredStocks = _stocks;
    } else {
      _filteredStocks = _stocks
          .where((stock) =>
              stock.productName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
