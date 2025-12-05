import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class ScanScreen extends StatefulWidget { // Screen to scan and select Bluetooth devices
  const ScanScreen({Key? key}) : super(key: key);

  @override 
  _ScanScreenState createState() => _ScanScreenState(); // State class
}

class _ScanScreenState extends State<ScanScreen> { 
  List<BluetoothDevice> _devicesList = [];
  bool _isLoading = true; 

  @override
  void initState() { // Initialize state
    super.initState();
    _getBondedDevices(); // Fetch bonded devices on init
  }

  // Get only the devices that are already paired with the phone
  Future<void> _getBondedDevices() async {
    setState(() {
      _isLoading = true;
    });
    List<BluetoothDevice> devices = [];
    try { //Wrap in try-catch to handle errors
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print("Error getting bonded devices: $e");
    }

    setState(() {
      _devicesList = devices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bluetooth Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getBondedDevices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = _devicesList[index];
                return ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text(device.address),
                  onTap: () {
                    // Connect to the selected device
                    context.read<DeviceProvider>().connect(device);
                  },
                );
              },
            ),
    );
  }
}