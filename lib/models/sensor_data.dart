class SensorData { //Model for sensor data
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorData({ //Constructor with named parameters
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  // Factory method to create SensorData from JSON map
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      timestamp: DateTime.now(),
    );
  }
}