import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class StatusScreen extends StatelessWidget { // Screen to show connection status and details
  const StatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Consumer to access the DeviceProvider 
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        final device = provider.connectedBluetoothDevice;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Connection Status'),
          ),
          body: Center(
            child: provider.isConnected && device != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        margin: const EdgeInsets.all(20.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                device.name ?? "Unknown Device",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(device.address),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider.statusMessage,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.bluetooth_disabled),
                        label: const Text('Disconnect'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          // Call the provider's disconnect method
                          provider.disconnect();
                          // Close this screen to return to the scan screen
                          Navigator.pop(context);
                        },
                      )
                    ],
                  )
                : const Text("No connected device."),
          ),
        );
      },
    );
  }
}