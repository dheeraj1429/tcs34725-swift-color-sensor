#include <Arduino.h>
#include <ArduinoBLE.h>

BLEService bleColourService("57ef795b-76cf-41f0-96d3-a7fa66c8da76");
BLECharacteristic bleColourChar("ae38c1be-6615-4461-9074-63b82a5457e4", BLERead | BLENotify, 3);

void setup() {
    Serial.begin(9600);

    BLE.setLocalName("ColorSensor");
    // Add characteristic to the service
    BLE.setAdvertisedService(bleColourService);
    bleColourService.addCharacteristic(bleColourChar);
    BLE.addService(bleColourService);

    BLE.advertise();
    Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {
    BLEDevice central = BLE.central();

    if (central && central.connected()) {
        Serial.print("Connected device address: ");
        Serial.println(central.address());
    } else {
        Serial.println("No device connected...");
    }

    delay(100);
}