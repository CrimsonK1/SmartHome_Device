import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:smart_device_tester/sensor_interface.dart';

// Definimos el Mock usando Mocktail como pide la tarea
class MockSensor extends Mock implements SensorInterface {}

void main() {
  group('Thermostat Unit Tests', () {
    late Thermostat thermostat;
    late MockSensor mockSensor;

    setUp(() {
      // Inicializamos el Mock y el Termostato antes de cada prueba
      mockSensor = MockSensor();
      thermostat = Thermostat(mockSensor);
    });

    // --- GRUPO 1: Control de Temperatura (setTargetTemperature) ---

    // 1. Prueba de rango normal (Tuya)
    test('should set temperature within normal range', () {
      final message = thermostat.setTargetTemperature(25.5);
      expect(thermostat.targetTemperature, 25.5);
      expect(message, 'Temperature set to 25.5 C.');
    });

    // 2. Prueba de límite superior excedido (Tuya mejorada)
    test('should limit to 30.0 C when set too high', () {
      final message = thermostat.setTargetTemperature(40.0);
      expect(thermostat.targetTemperature, 30.0);
      expect(message, contains('WARNING'));
      expect(message, contains('30.0 C'));
    });

    // 3. Prueba de límite inferior excedido (Tuya mejorada)
    test('should limit to 15.0 C when set too low', () {
      final message = thermostat.setTargetTemperature(10.0);
      expect(thermostat.targetTemperature, 15.0);
      expect(message, contains('WARNING'));
      expect(message, contains('15.0 C'));
    });

    // 4. Límite superior exacto
    test('should accept exact upper boundary 30.0', () {
      thermostat.setTargetTemperature(30.0);
      expect(thermostat.targetTemperature, 30.0);
    });

    // 5. Límite inferior exacto
    test('should accept exact lower boundary 15.0', () {
      thermostat.setTargetTemperature(15.0);
      expect(thermostat.targetTemperature, 15.0);
    });

    // 6. Justo debajo del límite superior
    test('should accept valid temp just below max (29.9)', () {
      thermostat.setTargetTemperature(29.9);
      expect(thermostat.targetTemperature, 29.9);
    });

    // 7. Justo arriba del límite inferior
    test('should accept valid temp just above min (15.1)', () {
      thermostat.setTargetTemperature(15.1);
      expect(thermostat.targetTemperature, 15.1);
    });

    // 8. Números negativos (debe limitarse a 15.0)
    test('should handle negative numbers by limiting to 15.0', () {
      thermostat.setTargetTemperature(-5.0);
      expect(thermostat.targetTemperature, 15.0);
    });

    // 9. Formato de decimales
    test('should format message with one decimal place', () {
      final message = thermostat.setTargetTemperature(20.1234);
      expect(message, 'Temperature set to 20.1 C.');
    });

    // 10. Valor inicial por defecto (según tu clase Thermostat es 20.0)
    test('should have default temperature of 20.0', () {
      // Creamos una nueva instancia para verificar el valor por defecto
      final newThermostat = Thermostat(mockSensor);
      expect(newThermostat.targetTemperature, 20.0);
    });

    // --- GRUPO 2: Interacción con Hardware (checkCurrentTemperature) ---
    // Aquí es donde Mocktail es OBLIGATORIO para la tarea

    // 11. Lectura exitosa del sensor
    test('should return sensor value when reading is successful', () async {
      // Arrange: Simulamos que el sensor responde 22.5
      when(() => mockSensor.getCurrentTemperature()).thenAnswer((_) async => 22.5);

      // Act
      final result = await thermostat.checkCurrentTemperature();

      // Assert
      expect(result, 22.5);
      // Verificamos que se llamó al sensor 1 vez
      verify(() => mockSensor.getCurrentTemperature()).called(1);
    });

    // 12. Manejo de error del sensor (Excepción)
    test('should return 0.0 (fallback) when sensor throws exception', () async {
      // Arrange: Simulamos fallo del hardware
      when(() => mockSensor.getCurrentTemperature()).thenThrow(Exception('Sensor Disconnected'));

      // Act
      final result = await thermostat.checkCurrentTemperature();

      // Assert
      expect(result, 0.0); // Tu código retorna 0.0 en catch
    });

    // 13. Lectura de temperatura alta del sensor
    test('should correctly relay high temperature from sensor', () async {
      when(() => mockSensor.getCurrentTemperature()).thenAnswer((_) async => 45.0);
      final result = await thermostat.checkCurrentTemperature();
      expect(result, 45.0);
    });

    // 14. Lectura de temperatura negativa del sensor
    test('should correctly relay negative temperature from sensor', () async {
      when(() => mockSensor.getCurrentTemperature()).thenAnswer((_) async => -10.0);
      final result = await thermostat.checkCurrentTemperature();
      expect(result, -10.0);
    });

    // 15. Verificar consistencia de llamadas múltiples
    test('should call sensor multiple times if method called twice', () async {
      when(() => mockSensor.getCurrentTemperature()).thenAnswer((_) async => 20.0);
      
      await thermostat.checkCurrentTemperature();
      await thermostat.checkCurrentTemperature();

      verify(() => mockSensor.getCurrentTemperature()).called(2);
    });
  });
}