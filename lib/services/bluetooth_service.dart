import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  // Plugin instance
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  // StreamController to broadcast incoming data
  final _dataStreamController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStreamController.stream;

  // Variable to reconstruct fragmented JSON messages
  String _messageBuffer = '';

  // Connect to a device using its address
  Future<void> connect(String address) async {
    if (_connection?.isConnected ?? false) {
      await disconnect();
    }
    try { //Wrap in try-catch to handle connection errors
      _connection = await BluetoothConnection.toAddress(address);
      _listenForData();
    } catch (e) {
      print('Error connecting: $e');
      throw Exception('Failed to connect to the device.');
    }
  }

  // Disconnect from the current device
  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
  }

  // Send a command as a JSON-encoded string
  Future<void> sendCommand(Map<String, dynamic> command) async {
    if (_connection?.isConnected ?? false) {
      String jsonCommand = jsonEncode(command);
      // JSON data must end with a newline character (\n)
      // so that the Arduino knows when a message ends.
      _connection!.output.add(Uint8List.fromList(utf8.encode("$jsonCommand\n")));
      await _connection!.output.allSent;
    } else {
      throw Exception('Not connected to any device.');
    }
  }

  // Listen for incoming data from the Arduino
  void _listenForData() {
    _connection?.input?.listen((Uint8List data) {
      // Convert bytes to a string
      String dataStr = utf8.decode(data);
      _messageBuffer += dataStr;

      // Search for complete messages (terminated with '\n') in the buffer
      while (_messageBuffer.contains('\n')) {
        int newlineIndex = _messageBuffer.indexOf('\n');
        String completeMessage = _messageBuffer.substring(0, newlineIndex).trim();
        _messageBuffer = _messageBuffer.substring(newlineIndex + 1);

        if (completeMessage.isNotEmpty) {
          // Add the complete JSON message to the stream
          _dataStreamController.add(completeMessage);
        }
      }
    }).onDone(() {
      disconnect();
    });
  }

  // Clean up resources
  void dispose() {
    _dataStreamController.close();
    disconnect();
  }
}