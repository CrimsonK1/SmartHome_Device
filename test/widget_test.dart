import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Importa tus archivos del proyecto (Asegúrate que las rutas coincidan con tu estructura real)
import 'package:smart_device_tester/main.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:smart_device_tester/sensor_interface.dart';

// Definimos el Mock del sensor
class MockSensor extends Mock implements SensorInterface {}

void main() {
  late MockSensor mockSensor;
  late Thermostat thermostat;

  setUp(() {
    mockSensor = MockSensor();
    thermostat = Thermostat(mockSensor);
  });

  // TEST 1: Renderizado básico e interacción de Slider (Original)
  testWidgets('Smart Thermostat UI renderiza y responde a interacción', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(thermostat: thermostat));

    expect(find.text('Smart Thermostat'), findsOneWidget);
    expect(find.text('Check Sensor'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    await tester.drag(find.byType(Slider), const Offset(50, 0)); 
    await tester.pump(); 

    expect(find.textContaining('Temperature set to'), findsOneWidget);
  });

  // TEST 2: Verificar el estado inicial preciso
  testWidgets('Estado inicial muestra temperatura exacta de 20.0', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(thermostat: thermostat));
    expect(find.text('Temperature set to 20.0'), findsOneWidget);
  });

  // TEST 3: Verificar interacción con el botón Check Sensor
  testWidgets('Botón Check Sensor es interactuable y no rompe la UI', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(thermostat: thermostat));
    final checkSensorBtn = find.text('Check Sensor');

    expect(checkSensorBtn, findsOneWidget);
    await tester.tap(checkSensorBtn);
    await tester.pump(); 
    expect(find.byType(Slider), findsOneWidget);
  });

  // TEST 4: Verificar estructura visual principal (Scaffold y AppBar)
  testWidgets('La estructura visual contiene un Scaffold y una AppBar', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(thermostat: thermostat));
    
    // Verificamos que la app tenga la estructura material básica
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  // TEST 5: Verificar interacción inversa del Slider (Izquierda)
  testWidgets('Deslizar hacia la izquierda actualiza la UI correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(thermostat: thermostat));

    // Movemos el slider hacia la izquierda (valores negativos)
    await tester.drag(find.byType(Slider), const Offset(-50, 0));
    await tester.pump();

    // Verificamos que el texto sigue presente y ha cambiado (no es el inicial 20.0)
    // Nota: Dependiendo de la implementación, el valor exacto puede variar, pero el widget debe existir.
    expect(find.textContaining('Temperature set to'), findsOneWidget);
    expect(find.text('Temperature set to 20.0'), findsNothing); // Confirmamos que cambió
  });

  // TEST 6: Verificar la raíz de la aplicación
  testWidgets('La raíz de la aplicación es un MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(thermostat: thermostat));
    
    // Es buena práctica verificar que el widget raíz configure el tema y rutas correctamente
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
