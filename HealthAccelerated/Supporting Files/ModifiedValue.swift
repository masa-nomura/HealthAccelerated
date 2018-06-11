//
//  Acceleration.swift
//  sendMotion
//
//  Created by Masakazu on 2018/06/09.
//  Copyright © 2018 Masakazu. All rights reserved.
//

import UIKit
import CoreMotion

struct ModifiedValue {
    
    struct Acceleration {
        var accData: Data
        let byte = 4
        
        init(accData: Data) {
            self.accData = accData
        }
        
        func toSomeValue() -> (x: Double, y: Double, z: Double) {
            let dataX = self.accData.subdata(in: 0..<byte)
            let dataY = self.accData.subdata(in: byte..<byte*2)
            let dataZ = self.accData.subdata(in: byte*2..<byte*3)
            
            let encodedX = NSString(data: dataX, encoding:String.Encoding.utf8.rawValue)
            let x = encodedX!.doubleValue
            let encodedY = NSString(data: dataY, encoding:String.Encoding.utf8.rawValue)
            let y = encodedY!.doubleValue
            let encodedZ = NSString(data: dataZ, encoding:String.Encoding.utf8.rawValue)
            let z = encodedZ!.doubleValue
            print(dataX)
            
            return (x, y, z)
            
        }
    }
    
    struct Attitude {
        
        var motionData: Data
        var byte = 5
        
        init(motionData: Data) {
            self.motionData = motionData
        }
        
        func toSomeValue() -> (x: Double, y: Double, z: Double, w: Double) {
            let dataX = self.motionData.subdata(in: 0..<byte)
            let dataY = self.motionData.subdata(in: byte..<byte*2)
            let dataZ = self.motionData.subdata(in: byte*2..<byte*3)
            let dataW = self.motionData.subdata(in: byte*3..<byte*4)

            let encodedX = NSString(data: dataX, encoding:String.Encoding.utf8.rawValue)
            let x = encodedX!.doubleValue
            let encodedY = NSString(data: dataY, encoding:String.Encoding.utf8.rawValue)
            let y = encodedY!.doubleValue
            let encodedZ = NSString(data: dataZ, encoding:String.Encoding.utf8.rawValue)
            let z = encodedZ!.doubleValue
            let encodedW = NSString(data: dataW, encoding:String.Encoding.utf8.rawValue)
            let w = encodedW!.doubleValue
            
            return (x, y, z, w)
        }
    }


}
