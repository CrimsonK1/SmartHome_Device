import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/device_provider.dart';
import 'services/bluetooth_service.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { // Root widget of the application
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceProvider(BluetoothService()),
      child: MaterialApp(
        title: 'Smart Home',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // We use a Consumer to decide the home screen
        home: Consumer<DeviceProvider>(
          builder: (context, provider, child) {
            // If the provider says it's connected, show the HomeScreen.
            // If not, show the ScanScreen for the user to choose a device.
            return provider.isConnected ? const HomeScreen() : const ScanScreen();
          },
        ),
      ),
    );
  }
}