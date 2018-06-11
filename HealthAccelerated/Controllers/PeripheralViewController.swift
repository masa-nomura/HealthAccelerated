//
//  ViewController.swift
//  sendMotion
//
//  Created by Masakazu on 2018/06/07.
//  Copyright © 2018 Masakazu. All rights reserved.
//

//
//  ViewController.swift
//  sendMotion
//
//  Created by Masakazu on 2018/06/07.
//  Copyright © 2018 Masakazu. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion
import SceneKit

enum SendOrder {
    case first
    case second
    
}

class PeripheralViewController: UIViewController {
    
    //MARK: - BLE
    var peripheralManager: CBPeripheralManager!
    
    var serviceUUID: CBUUID!
    var charOriXUUID: CBUUID!
    var charOriYUUID: CBUUID!
    var charOriZUUID: CBUUID!
    var charOriWUUID: CBUUID!
    var charAccXUUID: CBUUID!
    var charAccYUUID: CBUUID!
    var charAccZUUID: CBUUID!
    
    
    var service: CBMutableService!
    var charOriX: CBMutableCharacteristic!
    var charOriY: CBMutableCharacteristic!
    var charOriZ: CBMutableCharacteristic!
    var charOriW: CBMutableCharacteristic!
    var charAccX: CBMutableCharacteristic!
    var charAccY: CBMutableCharacteristic!
    var charAccZ: CBMutableCharacteristic!
    
    var sendOrder = SendOrder.first
    
    //MARK: - Motion
    var motionManager = CMMotionManager()
    var attitudeData: Data!
    
    var oriantationX = 0.0
    var oriantationY = 0.0
    var oriantationZ = 0.0
    var oriantationW = 0.0
    
    var timerMotion: Timer!
    
    //MARK: - Acceleration
    var timerAcc: Timer!
    var accData: Data!
    var accX = 0.0
    var accY = 0.0
    var accZ = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        setupBLE()
        setupMotion()
        setupAcceleration()
        sendData()
    }
    
    func setupMotion() {
        
        self.motionManager.gyroUpdateInterval = 1.0 / 60
        self.motionManager.startDeviceMotionUpdates()
        
        self.timerMotion = Timer(fire: Date(), interval: (1.0 / 60), repeats: true, block: { timer in
            
            if let data = self.motionManager.deviceMotion {
                
                let attitude = ModifiedData.Attitude(motion: data)
                guard let oneData = attitude.toOneData() else { return }
                self.attitudeData = oneData
                
                let orientation = self.orientationFromCMQuaternion(q: data.attitude.quaternion)
                self.oriantationX = Double(orientation.x)
                self.oriantationY = Double(orientation.y)
                self.oriantationZ = Double(orientation.z)
                self.oriantationW = Double(orientation.w)
            }
            
        })
        
        RunLoop.current.add(self.timerMotion, forMode: .defaultRunLoopMode)
        
    }
    
    func setupAcceleration() {
        
        self.motionManager.accelerometerUpdateInterval = 1.0 / 60
        self.motionManager.startAccelerometerUpdates()
        
        self.timerAcc = Timer(fire: Date(), interval: 1.0 / 60, repeats: true, block: { timer in
            
            if let data = self.motionManager.accelerometerData {
                
                if data.acceleration.x > 2 {
                    print("a-a")
                }
                let modifiedData = ModifiedData.Acceleration(acc: data)
                guard let oneData = modifiedData.toOneData() else { return }
                self.accData = oneData
                
                //                self.accX = data.acceleration.x
                //                self.accY = data.acceleration.y
                //                self.accZ = data.acceleration.z
                
            }
            
        })
        
        RunLoop.current.add(self.timerAcc, forMode: .defaultRunLoopMode)
        
    }
    
    func sendData() {
        
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            if self.attitudeData == nil || self.accData == nil {
                return
            }
            switch self.sendOrder {
            case .first:
                self.peripheralManager.updateValue(self.attitudeData, for: self.charOriX, onSubscribedCentrals: nil)
                self.sendOrder = .second
            case .second:
                self.peripheralManager.updateValue(self.accData, for: self.charAccX, onSubscribedCentrals: nil)
                self.sendOrder = .first
            }
        }
    }
    
    
    //    Thanks for https://qiita.com/noppefoxwolf/items/5c231c0d1f5a5f84fa7b
    private func orientationFromCMQuaternion(q: CMQuaternion) -> SCNVector4 {
        let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
        let gq2 = GLKQuaternionMake(Float(q.x), Float(q.y), Float(q.z), Float(q.w))
        let qp  = GLKQuaternionMultiply(gq1, gq2)
        let rq  = CMQuaternion(x: Double(qp.x), y: Double(qp.y), z: Double(qp.z), w: Double(qp.w))
        return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w))
    }
    
    private func setupBLE() {
        
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Motion"]
        
        self.serviceUUID = CBUUID(string: "0001")
        self.service = CBMutableService(type: self.serviceUUID, primary: true)
        
        self.charOriXUUID = CBUUID(string: "0002")
        self.charOriX = CBMutableCharacteristic(type: self.charOriXUUID, properties: .notify, value: nil, permissions: .readable)
        
        self.charAccXUUID = CBUUID(string: "0006")
        self.charAccX = CBMutableCharacteristic(type: self.charAccXUUID, properties: .notify, value: nil, permissions: .readable)
        
        self.service.characteristics = [self.charOriX, self.charAccX,]
        self.peripheralManager.add(self.service)
        self.peripheralManager.startAdvertising(advertisementData)
        
    }
    
}

extension PeripheralViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("error")
            return
        }
        print("OK")
    }
    
}


