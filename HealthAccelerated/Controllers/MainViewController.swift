//
//  ViewController.swift
//  HealthAccelerated
//
//  Created by Masakazu on 2018/06/05.
//  Copyright © 2018 Masakazu. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion
import CoreBluetooth
import Charts

class MainViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    
    //MARK: - Motion
    var motionManager = CMMotionManager()
    var cube: SCNNode!
    
    var oriantationX = 0.0
    var oriantationY = 0.0
    var oriantationZ = 0.0
    var oriantationW = 0.0
    
    var timerMotion: Timer!
    var timerAcc: Timer!
    var previousMotion: CMDeviceMotion?
    
    //MARK: - BLE
    var centralManager: CBCentralManager!
    var selectedPeripherals: [CBPeripheral]! = []
    var selectedChar: [CBCharacteristic]! = []
    
    var serviceUUID: CBUUID!
    var charOriXUUID: CBUUID!
    var charAccXUUID: CBUUID!
    
    //MARK: - GraphView
    @IBOutlet weak var accGraphView: AccGraph!
    var timerUpdate: Timer!
    var currentTime = 0.0
    var accX = 0.0
    var accY = 0.0
    var accZ = 0.0

    
    @IBAction func doubleTaped(_ sender: UITapGestureRecognizer) {
        accGraphView.cleardata()
        self.currentTime = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBLE()
//        setupAcceleration()
        setupMotion()
        setupUpdateGraph()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.centralManager.stopScan()
    }
    
    func setup() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [SCNDebugOptions.showBoundingBoxes, SCNDebugOptions.showCreases]
        
        let scene = SCNScene(named: "art.scnassets/model.scn")!
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 10)
        scene.rootNode.addChildNode(cameraNode)
        
        cube = scene.rootNode.childNode(withName: "Cube", recursively: true)
        
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.isPlaying = true
    }
    
    private func setupBLE() {
        self.serviceUUID = CBUUID(string: "0001")
        self.charOriXUUID = CBUUID(string: "0002")
        self.charAccXUUID = CBUUID(string: "0006")

        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setupMotion() {
        
//        self.motionManager.gyroUpdateInterval = 1.0 / 60
//        self.motionManager.startDeviceMotionUpdates()
        
        self.timerMotion = Timer(fire: Date(), interval: (1.0 / 60), repeats: true, block: { timer in
            
//            if let data = self.motionManager.deviceMotion {
                let oriantation = CMQuaternion(x: self.oriantationX,
                                               y: self.oriantationY,
                                               z: self.oriantationZ,
                                               w: self.oriantationW)
                self.cube.orientation = self.orientationFromCMQuaternion(q: oriantation)
                
//            }
            
        })
        
        RunLoop.current.add(self.timerMotion, forMode: .defaultRunLoopMode)
        
    }
    
    func setupAcceleration() {
        
//        self.motionManager.accelerometerUpdateInterval = 1.0 / 60
//        self.motionManager.startAccelerometerUpdates()
        
        self.timerAcc = Timer(fire: Date(), interval: 1.0 / 60, repeats: true, block: { timer in
            
            if let data = self.motionManager.accelerometerData {
                
                self.accX = data.acceleration.x
                self.accY = data.acceleration.y
                self.accZ = data.acceleration.z
            }
        })
        
        RunLoop.current.add(self.timerAcc, forMode: .defaultRunLoopMode)
        
    }
    
    func setupUpdateGraph() {
        
        self.timerUpdate = Timer(fire: Date(), interval: 0.1, repeats: true, block: { timer in
            self.accGraphView.updateValue(self.currentTime, self.accX, self.accY, self.accZ)
            self.currentTime = self.currentTime + 0.1
        })
        RunLoop.current.add(self.timerUpdate, forMode: .defaultRunLoopMode)
    }
    
//    Thanks for https://qiita.com/noppefoxwolf/items/5c231c0d1f5a5f84fa7b
    private func orientationFromCMQuaternion(q: CMQuaternion) -> SCNVector4 {
        let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
        let gq2 = GLKQuaternionMake(Float(q.x), Float(q.y), Float(q.z), Float(q.w))
        let qp  = GLKQuaternionMultiply(gq1, gq2)
        let rq  = CMQuaternion(x: Double(qp.x), y: Double(qp.y), z: Double(qp.z), w: Double(qp.w))
        return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w))
    }
}


extension MainViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

    }
}

extension MainViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("ready")
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("not ready")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        self.selectedPeripherals.append(peripheral)
        self.centralManager.connect(peripheral, options: nil)
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == self.serviceUUID {
                self.centralManager.connect(peripheral, options: nil)
                self.centralManager.stopScan()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([self.serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            return
        }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            peripheral.setNotifyValue(true, for: characteristic)

        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error")
            return
        }
        guard let receivedData = characteristic.value else { return }
        switch characteristic.uuid {
        case self.charOriXUUID:
            let motionData = ModifiedValue.Attitude(motionData: receivedData)
            (self.oriantationX, self.oriantationY, self.oriantationZ, self.oriantationW) = motionData.toSomeValue()
        case self.charAccXUUID:
            let accData = ModifiedValue.Acceleration(accData: receivedData)
            (self.accX, self.accY, self.accZ) = accData.toSomeValue()
        default:
            print("?")
        }
        
    }
}

