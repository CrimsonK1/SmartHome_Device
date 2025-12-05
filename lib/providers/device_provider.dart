import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../models/sensor_data.dart';
import '../services/bluetooth_service.dart'; 
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceProvider extends ChangeNotifier {
  // 1. STATE (PRIVATE)
  final BluetoothService _bluetoothService; 
  List<SmartDevice> _devices = [];
  SensorData? _currentSensorData;
  bool _isConnected = false;
  String _statusMessage = 'Disconnected';

  BluetoothDevice? _connectedBluetoothDevice; // Store the currently connected device
  AutomationProfile _activeProfile = AutomationProfile.factoryDefault; // Default profile
  Timer? _inactivityTimer;

  // Constructor
  DeviceProvider(this._bluetoothService) {
    _initializeDevices();
    _listenToBluetoothData(); // Start listening for incoming data
  }

  // 2. GETTERS (PUBLIC READ-ONLY ACCESS)
  List<SmartDevice> get devices => List.unmodifiable(_devices);
  SensorData? get currentSensorData => _currentSensorData;
  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;

   // Getter to access the connected Bluetooth device
   BluetoothDevice? get connectedBluetoothDevice => _connectedBluetoothDevice;
  
  AutomationProfile get activeProfile => _activeProfile;

  // 3. INTERNAL METHODS AND BUSINESS LOGIC
  void selectProfile(AutomationProfile profile) {
    _activeProfile = profile;
    print("Selected profile: $profile");
    _resetInactivityTimer(); // Starts countdown for inactivity automation
    notifyListeners(); // Notifies the UI to update the buttons
  }

  // Starts the timer. When it completes, it activates the automation on the Arduino
  void _startInactivityTimer() {
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      print("Inactivity detected. Activating profile: $_activeProfile");
      if (_activeProfile != AutomationProfile.none) {
        String profileName = _activeProfile.toString().split('.').last; // "factoryDefault", "mama", "papa"
        final command = {'action': 'start_profile', 'profile': profileName};
        _bluetoothService.sendCommand(command);
      }
    });
  }

  // Resets the timer. Called whenever the user interacts
  void _resetInactivityTimer() {
    // First, stop any active automation on the Arduino
    if (_isConnected) {
       final command = {'action': 'stop_profile'};
       _bluetoothService.sendCommand(command);
    }
    // Cancels the previous timer
    _inactivityTimer?.cancel();
    // Starts a new one
    _startInactivityTimer();
  }

  // Initialize the list of devices
  void _initializeDevices() {
    _devices = [
      SmartDevice(id: 'led1', name: 'LED LivingRoom', type: DeviceType.led),
      SmartDevice(id: 'led2', name: 'LED Bedroom', type: DeviceType.led),
      SmartDevice(id: 'servo1', name: 'Window Blinds', type: DeviceType.servo),
      SmartDevice(id: 'servo2', name: 'Door Lock', type: DeviceType.servo),
      // Add a sensor device to represent sensor data
      SmartDevice(id: 'sensor_cluster', name: 'Environmental Sensors', type: DeviceType.sensor, isOn: true),
    ];
  }

  Future<void> toggleLcdDisplay() async {
    _resetInactivityTimer(); // Resets the timer
    if (!_isConnected) return;
    try {
      // No specific device ID needed for this command
      final command = {'action': 'toggle_lcd'};
      await _bluetoothService.sendCommand(command);
      _statusMessage = 'LCD command sent';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error sending command to LCD: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Connect and Disconnect
   Future<void> connect(BluetoothDevice device) async {
    try {
      _statusMessage = 'Connecting to ${device.name}...';
      notifyListeners();
      await _bluetoothService.connect(device.address);
      _isConnected = true;
      _connectedBluetoothDevice = device; // Store the connected device
      _statusMessage = 'Connected successfully';
      _resetInactivityTimer(); // Starts the inactivity cycle
      notifyListeners();
      await requestSensorData();
    } catch (e) {
      _isConnected = false;
      _connectedBluetoothDevice = null; // Store null in case of error
      _statusMessage = 'Connection failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetoothService.disconnect();
      _isConnected = false;
      _connectedBluetoothDevice = null; // Store null when disconnecting
      _statusMessage = 'Disconnected';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error disconnecting: ${e.toString()}';
      notifyListeners();
    }
  }

  // Logic for LED toggle
  Future<void> toggleDevice(String deviceId) async {
    _resetInactivityTimer(); // Resets the timer
    if (!_isConnected) return;
    try {
      final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return;
      final device = _devices[deviceIndex];
      device.isOn = !device.isOn;
      
      // Send command to Arduino
      final command = {'device': deviceId, 'action': device.isOn ? 'on' : 'off'};
      await _bluetoothService.sendCommand(command);

      _statusMessage = '${device.name} has been turned ${device.isOn ? "on" : "off"}';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  // Logic for Servo control
  Future<void> setServoAngle(String deviceId, int angle) async {
    _resetInactivityTimer(); // Resets the timer
    if (!_isConnected) return;
    try {
      if (angle < 0 || angle > 180) {
        _statusMessage = 'Invalid angle. Must be between 0-180';
        notifyListeners();
        return;
      }
      final command = {'device': deviceId, 'action': 'angle', 'value': angle};
      await _bluetoothService.sendCommand(command);
      _statusMessage = 'Servo moved to $angle degrees';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error controlling servo: ${e.toString()}';
      notifyListeners();
    }
  }

  // Logic to listen for incoming Bluetooth data
  void _listenToBluetoothData() {
    _bluetoothService.dataStream.listen((data) {
      try {
        final jsonData = json.decode(data);
        // Asume sensor data with key 'temperature'
        if (jsonData.containsKey('temperature')) {
          _currentSensorData = SensorData.fromJson(jsonData);
          _statusMessage = 'Sensor data updated';
          notifyListeners();
        }
      } catch (e) {
        print('Error parsing sensor data: $e');
      }
    });
  }

  Future<void> requestSensorData() async { // Request sensor data from Arduino
    if (!_isConnected) return;
    try {
      final command = {'action': 'read_sensors'};
      await _bluetoothService.sendCommand(command);
    } catch (e) {
      _statusMessage = 'Error requesting sensor data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Cleanup resources
  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }
}