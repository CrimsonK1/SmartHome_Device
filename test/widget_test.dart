import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart'; // Necesario para crear el mock

// Importa tus archivos del proyecto
import 'package:smart_device_tester/main.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:smart_device_tester/sensor_interface.dart';

// Definimos el Mock del sensor para que la UI pueda construirse sin hardware real
class MockSensor extends Mock implements SensorInterface {}

void main() {
  late MockSensor mockSensor;
  late Thermostat thermostat;

  setUp(() {
    mockSensor = MockSensor();
    // Inicializamos el termostato con el mock
    thermostat = Thermostat(mockSensor);
  });

  testWidgets('Smart Thermostat UI renderiza y responde a interacción', (WidgetTester tester) async {
    // 1. ARRANGE: Construir la app inyectando el termostato
    // Nota: MyApp ahora pide 'thermostat' en el constructor según el código que te di para main.dart
    await tester.pumpWidget(MyApp(thermostat: thermostat));

    // 2. ASSERT (Renderizado): Verificar que los elementos visuales existen
    // Verificamos que aparezca el título de la AppBar
    expect(find.text('Smart Thermostat'), findsOneWidget);
    // Verificamos que aparezca el botón de checar sensor
    expect(find.text('Check Sensor'), findsOneWidget);
    // Verificamos que aparezca el Slider de temperatura
    expect(find.byType(Slider), findsOneWidget);

    // 3. ACT (Interacción): Mover el Slider
    // El valor inicial es 20.0. Hacemos un drag (arrastre) hacia la derecha para cambiar el valor.
    await tester.drag(find.byType(Slider), const Offset(50, 0)); 
    
    // Forzamos la reconstrucción del widget para ver los cambios (pump)
    await tester.pump(); 

    // 4. ASSERT (Resultado): Verificar que el mensaje de estado cambió
    // Al mover el slider, el texto de abajo debe actualizarse con la nueva temperatura.
    // Usamos find.textContaining porque el número exacto depende de cuánto se movió el slider.
    expect(find.textContaining('Temperature set to'), findsOneWidget);
  });
}