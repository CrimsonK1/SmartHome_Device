import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

// Importa tus archivos del proyecto
import 'package:smart_device_tester/main.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:smart_device_tester/sensor_interface.dart';

// Definimos el Mock del Hardware
class MockSensor extends Mock implements SensorInterface {}

void main() {
  // OBLIGATORIO: Inicializar el binding para pruebas de integración
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSensor mockSensor;
  late Thermostat thermostat;

  setUp(() {
    mockSensor = MockSensor();
    thermostat = Thermostat(mockSensor);
  });

  group('E2E Smart Home Tests', () {
    
    // --- ESCENARIO 1: Éxito (Flujo Completo) ---
    testWidgets('Full Flow: UI requests temp, Hardware responds, UI updates', (tester) async {
      // 1. ARRANGE: Configuramos el hardware simulado para responder 28.5
      when(() => mockSensor.getCurrentTemperature()).thenAnswer((_) async => 28.5);

      // Iniciamos la app completa (inyectando dependencias)
      await tester.pumpWidget(MyApp(thermostat: thermostat));
      await tester.pumpAndSettle(); // Esperamos a que cargue todo

      // 2. ACT: El usuario toca el botón "Check Sensor"
      // Nota: Asegúrate que el texto coincida con el que pusimos en main.dart
      final checkButton = find.text('Check Sensor');
      
      // Verificamos que el botón existe antes de tocarlo
      expect(checkButton, findsOneWidget);
      await tester.tap(checkButton);
      
      // Esperamos a que la operación asíncrona termine y la UI se redibuje
      await tester.pumpAndSettle();

      // 3. ASSERT: Verificamos que la UI muestra el valor que envió el hardware
      expect(find.text('28.5 °C'), findsOneWidget);
    });

    // --- ESCENARIO 2: Fallo (Manejo de Errores) ---
    testWidgets('Error Flow: Hardware fails, UI handles gracefully (0.0)', (tester) async {
      // 1. ARRANGE: Configuramos el hardware para fallar (Simular desconexión)
      when(() => mockSensor.getCurrentTemperature()).thenThrow(Exception('Connection Failed'));

      await tester.pumpWidget(MyApp(thermostat: thermostat));
      await tester.pumpAndSettle();

      // 2. ACT: Intentamos obtener la temperatura
      await tester.tap(find.text('Check Sensor'));
      await tester.pumpAndSettle();

      // 3. ASSERT: La app NO debe crashear. 
      // Según tu lógica en thermostat.dart, retorna 0.0 si hay error.
      expect(find.text('0.0 °C'), findsOneWidget);
    });
  });
}