import 'sensor_interface.dart';

class Thermostat{
  final SensorInterface _sensor;
  double _targetTemperature = 20.0; //Default initial temperature

  //Constructor now requires a sensor (dependency injection)
  Thermostat(this._sensor);

  double get targetTemperature => _targetTemperature;

  //Unit to test: adjusts in temperature and returns status message
  String setTargetTemperature(double newTemp) {
    if (newTemp <15.0) {
      _targetTemperature = 15.0;
      return 'WARNING: Temperature too low, mainatined at 15.0 C.';
    }
    if (newTemp > 30.0) {
      _targetTemperature = 30.0;
      return 'WARNING: Temperature too high, mainatined at 30.0 C.';
    }
    _targetTemperature = newTemp;
    return 'Temperature set to ${newTemp.toStringAsFixed(1)} C.';
  } 

  //New unit to test: check current temperature from sensor
  Future<double> checkCurrentTemperature() async {
    try {
      final currentTemp = await _sensor.getCurrentTemperature();
      return currentTemp;
    } catch (e) {
      print('ERROR: Sensor failed. ${e.toString()}');
      return 0.0; //Safe fallback value
    }
  }
}