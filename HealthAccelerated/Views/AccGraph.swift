//
//  AccGraph.swift
//  HealthAccelerated
//
//  Created by Masakazu on 2018/06/08.
//  Copyright © 2018 Masakazu. All rights reserved.
//

import UIKit
import ARKit
import Charts
import SpriteKit

class AccGraph: LineChartView {
    
    var times: [Double] = []
    var accX: [Double] = []
    var accY: [Double] = []
    var accZ: [Double] = []
    
    var chartdata = LineChartData()
    
    var lineChartEntryX = [ChartDataEntry]()
    var lineChartEntryY = [ChartDataEntry]()
    var lineChartEntryZ = [ChartDataEntry]()
    
    let biasTime = 20.0
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup() {
        
    }
    
    func cleardata() {
        self.accX.removeAll()
        self.accY.removeAll()
        self.accZ.removeAll()
        self.lineChartEntryX.removeAll()
        self.lineChartEntryY.removeAll()
        self.lineChartEntryZ.removeAll()
        
        let dataSetX = createDataSet(values: lineChartEntryX, color: .blue, label: "accX")
        let dataSetY = createDataSet(values: lineChartEntryY, color: .red, label: "accY")
        let dataSetZ = createDataSet(values: lineChartEntryZ, color: .green, label: "accZ")
        
        self.chartdata.clearValues()
        self.chartdata.addDataSet(dataSetX)
        self.chartdata.addDataSet(dataSetY)
        self.chartdata.addDataSet(dataSetZ)
        
        self.data = self.chartdata
    }
    
    func updateValue(_ time: Double, _ accX: Double, _ accY: Double, _ accZ: Double) {
        self.times.append(time)
        self.accX.append(accX)
        self.accY.append(accY)
        self.accZ.append(accZ)
        
        let entryX = ChartDataEntry(x: time, y: accX)
        let entryY = ChartDataEntry(x: time, y: accY)
        let entryZ = ChartDataEntry(x: time, y: accZ)
        
        self.lineChartEntryX.append(entryX)
        self.lineChartEntryY.append(entryY)
        self.lineChartEntryZ.append(entryZ)
        
        let dataSetX = createDataSet(values: lineChartEntryX, color: .blue, label: "accX")
        let dataSetY = createDataSet(values: lineChartEntryY, color: .red, label: "accY")
        let dataSetZ = createDataSet(values: lineChartEntryZ, color: .green, label: "accZ")

        self.chartdata.clearValues()
        self.chartdata.addDataSet(dataSetX)
        self.chartdata.addDataSet(dataSetY)
        self.chartdata.addDataSet(dataSetZ)
        
        self.xAxis.axisMinimum = time - biasTime
        self.xAxis.axisMaximum = self.xAxis.axisMinimum + 40.0
        
        self.data = self.chartdata
    }
    
    func createDataSet(values: [ChartDataEntry] = [], color: UIColor, label: String) -> LineChartDataSet {
        let dataSet = LineChartDataSet(values: values, label: label)
        dataSet.colors = [color]
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 3
        return dataSet
    }
}
