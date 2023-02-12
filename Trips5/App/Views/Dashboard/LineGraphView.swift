//
//  LineGraphView.swift
//  Trips5
//
//  Created by Rob Goble on 2/6/23.
//

import Charts
import SwiftUI

struct LineGraphData: Identifiable, Hashable {
    let id = UUID()
    var chartLabel: String
    
    var xLabelKey: String
    var yLabelKey: String
    
    var averageValue: Double
    var minValue: Double
    var maxValue: Double
    
    var entries: [LineGraphEntry]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LineGraphEntry: Identifiable, Hashable {
    let id = UUID()
    var label: Date
    var value: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LineGraphView: View {
    var data: LineGraphData
    
    var body: some View {
        Chart(data.entries) { entry in
            LineMark(x: .value(data.xLabelKey, entry.label, unit: .month), y: .value(data.yLabelKey, entry.value))
                .interpolationMethod(.catmullRom)
                .symbol(by: .value("", data.yLabelKey))
            RuleMark(y: .value("Average", data.averageValue))
                .foregroundStyle(.orange)
                .lineStyle(.init(lineWidth: 2, dash: [8, 8]))
                .annotation(position: .bottom, alignment: .leading, spacing: 2.0, content: {
                    Text(data.averageValue.formatted()).font(.caption2)
                })
        }.chartYScale(domain: clampedMin()...clampedMax())
    }
    
    private func clampedMin() -> Double {
        let min = data.minValue - ((data.maxValue - data.minValue) * 0.2)
        
        return data.minValue < Double.greatestFiniteMagnitude ? min : Double.leastNormalMagnitude
    }
    
    private func clampedMax() -> Double {
        let max = data.maxValue + ((data.maxValue - data.minValue) * 0.2)
        
        return data.maxValue > Double.leastNormalMagnitude ? max : Double.greatestFiniteMagnitude
    }
}
