//
//  NearbyParties.swift
//  BoomBox
//
//  Created by Darren Matthew on 11/26/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import CoreBluetooth

class Nearby: NSObject {

    static let shared = Nearby()
    
    let serviceId = CBUUID(string: "0C9177E3-F0E2-4113-9321-202FB9231907")
    
    //var deviceId = UIDevice.current.identifierForVendor!.uuidString
    
    let charId = CBUUID(string: "B1428E10-9894-4D5E-BB39-9136E124CA10")

    var peripheral: CBPeripheral?
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: .none, options: .none)
        print("initialized")
        //peripheralManager = CBPeripheralManager(delegate: self, queue: .none, options: .none)
    }
    
    func advertise() {
        print("called advertise")
        
        let char = CBMutableCharacteristic(type: charId, properties: [.read], value: "G".data(using: .utf8), permissions: [.readable])

        /*
        let descId = CBUUID(string: CBUUIDCharacteristicUserDescriptionString)
        let descriptor = CBMutableDescriptor(type: descId, value: "MYDESCRIPTOROMG")
        char.descriptors = [descriptor]
        */
        
        let service = CBMutableService(type: serviceId, primary: true)
        service.characteristics = [char]
        peripheralManager.add(service)

        //print("advertising service: \(service.uuid), char value: \(char.value?.utf8string)")
        
        let data = Party.shared.code!
        
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceId],
            CBAdvertisementDataLocalNameKey: data
            ])

    }
    
    func scan() {
        centralManager.scanForPeripherals(withServices: [serviceId], options: .none)
    }
}

extension Nearby: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("started advertising")
        if let error = error {
            print("Advertising ERROR: \(error.localizedDescription)")
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
            
        case .poweredOn:
            advertise()
            
        case .poweredOff, .unknown, .unsupported, .resetting, .unauthorized:
            
            print("NO BLUETOOTH :(")
            break
        @unknown default:
            break
        }
    }
}


extension Nearby: CBCentralManagerDelegate {
    
    // Successfully connected a BLE peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print(#function)
        peripheral.discoverServices(.none)
    }
    
    // BLE peripheral discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        if let party_code = advertisementData[CBAdvertisementDataLocalNameKey] {
            print(party_code)
        }
    }
    
    // Whenever device state changes
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .poweredOn:
            scan()
            
        case .poweredOff, .unknown, .unsupported, .resetting, .unauthorized:
            print("NO BLUETOOTH :(")
            break
        @unknown default:
            break
        }
    }
}

extension Nearby: CBPeripheralDelegate {
    
    // Peripherals services discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        peripheral.services?.filter { $0.uuid == serviceId }.forEach { service in
            peripheral.discoverCharacteristics(.none, for: service)
        }
    }
    
    // Peripheral characteristics discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        service.characteristics?.forEach { char in
            //print("CHAR id: \(char.uuid.uuidString) VALUE: \(char.value?.utf8string)")
            peripheral.readValue(for: char)
            //peripheral.discoverDescriptors(for: char)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print(characteristic.value?.utf8string)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        characteristic.descriptors?.forEach { desc in
            print("SERVICE \(desc.characteristic.service.uuid.uuidString), DESC: \(desc)")
        }
    }
}
