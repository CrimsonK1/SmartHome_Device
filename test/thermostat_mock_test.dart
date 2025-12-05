import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'mock_sensor.dart';

void main() {
  late Thermostat thermostat;
  late MockSensor mockSensor;

  setUp((){
    //Arrange: Initialize mock and thermostat with injected mock
    mockSensor = MockSensor();
    thermostat = Thermostat(mockSensor);
  });

  group('Thermostat integration with mocked sensor',() {
    test('should return temperature when sensor responds correctly', () async {
      const expectedTemp = 23.5;

      //Arrange: Use when() to tell Mocktail what to retun
      when (() => mockSensor.getCurrentTemperature())
        .thenAnswer((_) async => expectedTemp);
      
      //Act: Execute the unit
      final currentTemp = await thermostat.checkCurrentTemperature();

      //Assert: Verify expected result
      expect(currentTemp, expectedTemp);
    });
    test('should handle exception and return 0.0 (Sensor Failure Test)', () async {
      //Arrange: Create simulated exception
      final exception =Exception('I2C bus read error');

      //Arrange: Usen when() to simulate sensor failure
      when(() => mockSensor.getCurrentTemperature())
        .thenThrow(exception);

      //Act: Execute unit (checkCurrentTemperature handles exception internally)
      final currentTemp = await thermostat.checkCurrentTemperature();

      //Assert: Verify unit returns safe fallback value to 0.0
      expect(currentTemp, 0.0);
    }); 
  });
}
  
