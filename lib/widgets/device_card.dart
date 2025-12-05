import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class DeviceCard extends StatelessWidget {
  final SmartDevice device;

  const DeviceCard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Consumer to rebuild the card when the device state changes (e.g., isOn)
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        // Find the latest version of the device from the provider
        // to ensure the state (isOn) is always up to date.
        final latestDevice = provider.devices.firstWhere((d) => d.id == device.id);

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(
              _getDeviceIcon(latestDevice.type),
              color: latestDevice.isOn ? Colors.lightGreenAccent : Colors.grey,
              size: 32,
            ),
            title: Text(latestDevice.name),
            subtitle: _buildSubtitle(context, latestDevice), // Dynamic subtitle
            // The control widget is now dynamic
            trailing: _buildTrailingWidget(context, latestDevice),
          ),
        );
      },
    );
  }

  // METHOD: Get icon based on device type
  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.led:
        return Icons.lightbulb_outline;
      case DeviceType.servo:
        return Icons.rotate_right;
      case DeviceType.sensor:
        return Icons.sensors;
    }
  }
  
  // METHOD: Build the trailing widget based on device type
  Widget _buildTrailingWidget(BuildContext context, SmartDevice device) {
    final provider = context.read<DeviceProvider>();

    switch (device.type) { // Different controls for different device types
      case DeviceType.led:
        return Switch(
          value: device.isOn,
          onChanged: (value) {
            provider.toggleDevice(device.id);
          },
        );
      case DeviceType.servo:
        // For a servo, we show a button that could open a dialog with a slider.
        // For now, it's just a button.
        return IconButton(
          icon: const Icon(Icons.settings_ethernet), // Icon for control
          onPressed: () {
            // Here we could open an AlertDialog or a new screen
            // for the user to select the angle with a Slider.
            // Quick example: move it to 90 degrees.
            provider.setServoAngle(device.id, 90);
          },
        );
      case DeviceType.sensor:
        // For sensors, there is no control, so we don't show anything.
        return const SizedBox.shrink(); // An empty widget
    }
  }

  // METHOD: Show a relevant subtitle
  Widget _buildSubtitle(BuildContext context, SmartDevice device) {
     if (device.type == DeviceType.sensor) {
        // If it's a sensor, we listen to the provider's data to show it
        return Consumer<DeviceProvider>(
          builder: (context, provider, child) {
            final data = provider.currentSensorData;
            if (data == null) return const Text('Waiting for data...');
            // We assume all sensors show the same data for now
            return Text('Temp: ${data.temperature}°C, Hum: ${data.humidity}%');
          },
        );
     } else {
        // For LED and Servo, we show their ON/OFF state
        return Text(device.isOn ? 'ON' : 'OFF');
     }
  }
}