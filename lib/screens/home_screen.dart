import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/device_card.dart';
import '../screens/status_screen.dart';
import '../models/device.dart';

class HomeScreen extends StatelessWidget { // Main screen of the app
 const HomeScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) { // Build the UI
  return Scaffold(
    appBar: AppBar(
       title: const Text('Smart Home Control'),
        // Add an info button to navigate to the status screen
        actions: [
          IconButton(
            icon: const Icon(Icons.tv), // TV icon for LCD display
            tooltip: 'Control LCD Screen',
            onPressed: () {
              // Call the new LCD method from the provider
              context.read<DeviceProvider>().toggleLcdDisplay();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Navigate to the status screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatusScreen()),
              );
            },
          )
        ],
      ),

   body: Column(
    children: [
      // Connection Status
      Consumer<DeviceProvider>(
        builder: (context, provider, child) {
          return Container( // Color-coded status bar
            padding: const EdgeInsets.all(16),
            color: provider.isConnected ? Colors.green : Colors.red,
            child: Row(
              children: [
               Icon(
                provider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: Colors.white,
               ),
               const SizedBox(width: 8),
               Text(
                provider.statusMessage,
                style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },     
      ),
      _buildProfileSelector(context),
      // Device List
      Expanded(
        child: Consumer<DeviceProvider>(
          builder: (context, provider, child) {
            return ListView.builder( // Build a list of devices
              itemCount: provider.devices.length,
              itemBuilder: (context, index) {
                final device = provider.devices[index];
                return DeviceCard(device: device);
              },
             );
            },
           ),
          ),
         ],
        ),
       );
      }
     }

     Widget _buildProfileSelector(BuildContext context) { // Widget for selecting automation profiles
    return Padding( // Padding around the selector
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Consumer<DeviceProvider>( // Listen to provider changes
        builder: (context, provider, child) {
          return Wrap( 
            spacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Default'),
                selected: provider.activeProfile == AutomationProfile.factoryDefault,
                onSelected: (selected) {
                  if (selected) provider.selectProfile(AutomationProfile.factoryDefault);
                },
              ),
              ChoiceChip(
                label: const Text('Mama'),
                selected: provider.activeProfile == AutomationProfile.mama,
                onSelected: (selected) {
                  if (selected) provider.selectProfile(AutomationProfile.mama);
                },
              ),
              ChoiceChip(
                label: const Text('Papa'),
                selected: provider.activeProfile == AutomationProfile.papa,
                onSelected: (selected) {
                  if (selected) provider.selectProfile(AutomationProfile.papa);
                },
              ),
            ],
          );
        },
      ),
    );
  }
