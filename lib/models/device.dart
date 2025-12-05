class SmartDevice { //Model for smart devices
  final String id;
  final String name;
  final DeviceType type;
  bool isOn;

  SmartDevice({ // Constructor with named parameters
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
  });

}

enum DeviceType { led, servo, sensor } // Types of devices

enum AutomationProfile { // Automation profiles
  none, // No automation (when using manual control)
  factoryDefault,
  mama,
  papa
}