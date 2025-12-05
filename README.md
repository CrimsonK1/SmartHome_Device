# Smart Home Controller

Final version of a flutter app that works with Arduino via Bluetooth communication

The Arduino device is connected to a DHT22 sensor, a sg90 servomotor, two LEDs and an LCD display. An HC-05 module is required for bluetooth connection.
This final version integrates unit testing and quality assurance techniques to provide maximum product quality.

## IMPORTANT FOR BLUETOOTH SERIAL SET-UP

It's vital to configure the proper Android permissions to use Bluetooth communication tools and protocols.
The AndroidManifest.xml in the Android folder of this repository should have everything correctly, but if an exception occurs
with flutter_bluetooth_serial, a possible solution is to add the namespace configuration manually to the package.

First locate the bluetooth serial package in your storage, then follow => flutter_bluetooth_serial-0.4.0\android\build.gradle.

Then find the android {...} and add " namespace 'flutter.bluetooth.serial' " at the beginning without changing anything else.

In the same package, go to => android\src\main\AndroidManifest.xml

Look for the <manifest..> tag, and if you see a line " package="io.github.edufolly.flutterbluetoothserial" ", delete it and don't change anything else.

Everything should be just fine now

## IMPORTANT FOR ARDUINO
You'll need to download the 'DHT sensor library' from Adafruit and the 'ArduinoJson' from Benoit Blanchon in the Arduino IDE.
