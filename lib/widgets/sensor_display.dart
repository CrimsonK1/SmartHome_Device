import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class SensorDisplay extends StatelessWidget { // Widget to display sensor data
  const SensorDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) { // Build the UI
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        final sensorData = provider.currentSensorData;

        // The refresh button now depends on the connection status
        final isConnected = provider.isConnected;

        return Card( // Card to display sensor information
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Enviromental Sensor Data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // If there is no data, show a message
                if (sensorData == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('Press Refresh to get data...'),
                  )
                else
                  // If there is data, show it
                  Column(
                    children: [
                      _buildSensorRow(
                        'Temperature',
                        '${sensorData.temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        Colors.red,
                      ),
                      _buildSensorRow(
                        'Humidity',
                        '${sensorData.humidity.toStringAsFixed(1)}%',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  // The button is only enabled if we are connected
                  onPressed: isConnected ? () => provider.requestSensorData() : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // METHOD: Build a row for a sensor reading
  Widget _buildSensorRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}