//
//  Acceleration.swift
//  sendMotion
//
//  Created by Masakazu on 2018/06/09.
//  Copyright © 2018 Masakazu. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit

struct ModifiedData {
    
    struct Acceleration {
        var x: Double
        var y: Double
        var z: Double
        let byte = 4
        
        init(acc: CMAccelerometerData) {
            self.x = acc.acceleration.x
            self.y = acc.acceleration.y
            self.z = acc.acceleration.z
            print(self.x)
        }
        
        func toOneData() -> Data? {
            var data = Data()
            
            let dataX = String(self.x).data(using: .utf8)!
            let dataY = String(self.y).data(using: .utf8)!
            let dataZ = String(self.z).data(using: .utf8)!
//            print(NSString(data: dataX, encoding:String.Encoding.utf8.rawValue)!.doubleValue)
            if dataX.indices.max()! < byte || dataY.indices.max()! < byte || dataY.indices.max()! < byte {
                return nil
            } else {
                data.append(dataX.subdata(in: 0..<byte))
                data.append(dataY.subdata(in: 0..<byte))
                data.append(dataZ.subdata(in: 0..<byte))
                return data
            }
            
        }
    }
    
    struct Attitude {
        let byte = 5
        var x: Double!
        var y: Double!
        var z: Double!
        var w: Double!
        
        init(motion: CMDeviceMotion) {
            let attitude = orientationFromCMQuaternion(q: motion.attitude.quaternion)
            self.x = Double(attitude.x)
            self.y = Double(attitude.y)
            self.z = Double(attitude.z)
            self.w = Double(attitude.w)
        }
        
        func toOneData() -> Data? {
            var data = Data()
            
            let dataX = String(self.x).data(using: .utf8)!
            let dataY = String(self.y).data(using: .utf8)!
            let dataZ = String(self.z).data(using: .utf8)!
            let dataW = String(self.w).data(using: .utf8)!
            
            if dataX.indices.max()! < byte || dataY.indices.max()! < byte || dataY.indices.max()! < byte || dataW.indices.max()! < byte {
                return nil
            } else {
                data.append(dataX.subdata(in: 0..<byte))
                data.append(dataY.subdata(in: 0..<byte))
                data.append(dataZ.subdata(in: 0..<byte))
                data.append(dataW.subdata(in: 0..<byte))
                return data
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
    }

}
