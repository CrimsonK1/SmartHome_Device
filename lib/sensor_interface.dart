abstract class SensorInterface {
  // Returns current temperature. Future because reading is asynchronous.
  Future<double> getCurrentTemperature();
}