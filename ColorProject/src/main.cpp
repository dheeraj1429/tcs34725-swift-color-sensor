#include <Adafruit_TCS34725.h>
#include <Arduino.h>
#include <ArduinoBLE.h>
#include <ArduinoJson.h>
#include <Wire.h>

BLEService bleColourService("57ef795b-76cf-41f0-96d3-a7fa66c8da76");
// BLE characteristic size: estimate max JSON size and add buffer
// Current JSON worst case: ~55 bytes, using 128 for future expansion
BLEStringCharacteristic bleColourChar("ae38c1be-6615-4461-9074-63b82a5457e4", BLERead | BLENotify, 128);

Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_24MS, TCS34725_GAIN_1X);

void setup() {
    Serial.begin(9600);

    if (!tcs.begin()) {
        Serial.println("Tcs34725 module not found!");
        while (1);
    }

    while (!BLE.begin()) {
        Serial.println("Starting Bluetooth® Low Energy module failed!");
        while (1);
    }

    BLE.setLocalName("ColorSensor");
    BLE.setAdvertisedService(bleColourService);

    bleColourService.addCharacteristic(bleColourChar);
    BLE.addService(bleColourService);

    BLE.advertise();
    Serial.println("Bluetooth device active, waiting for connections...");
    Serial.println("Found Tcs34725 module");
}

void loop() {
    BLEDevice central = BLE.central();

    if (central && central.connected()) {
        Serial.print("Connected device address: ");
        Serial.println(central.address());

        uint16_t r, g, b, c, lux;
        tcs.getRawData(&r, &g, &b, &c);
        lux = tcs.calculateLux(r, g, b);

        JsonDocument doc;
        doc["r"] = r;
        doc["g"] = g;
        doc["b"] = b;
        doc["c"] = c;
        doc["lux"] = lux;

        String output;
        serializeJson(doc, output);

        // Safety check: warn if JSON is too large
        if (output.length() > 128) {
            Serial.print("WARNING: JSON too large (");
            Serial.print(output.length());
            Serial.println(" bytes). Increase characteristic size!");
        }

        bleColourChar.writeValue(output);

        Serial.print("Sent JSON (");
        Serial.print(output.length());
        Serial.print(" bytes): ");
        Serial.println(output);
    }

    delay(2000);
}