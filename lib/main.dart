import 'package:flutter/material.dart';
import 'package:product_mgmt_app/viewmodels/customer_viewmodel.dart';
import 'package:product_mgmt_app/viewmodels/product_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_screen.dart';
import 'views/product_management_screen.dart';
import 'viewmodels/auth_viewmodel.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  String? token = await getSavedToken(); 

  runApp(MyApp(initialRoute: token != null ? '/products' : '/login'));
}

Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("token");
}

class MyApp extends StatelessWidget {
   final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
            create: (_) => CustomerViewModel()),  
        ChangeNotifierProvider(
            create: (_) => ProductViewModel()),  
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, initialRoute: initialRoute,
        // initialRoute: '/',
        routes: {
        '/login': (context) => LoginScreen(),
          '/products': (context) => ProductManagementScreen(),
        },
      ),
    );
  }
}