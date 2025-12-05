import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/sensor_interface.dart';

//Create Mock class. Extends Mock and implements interface to simulate
class MockSensor extends Mock implements SensorInterface {}