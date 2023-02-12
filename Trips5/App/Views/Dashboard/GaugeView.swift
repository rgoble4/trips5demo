//
//  GaugeView.swift
//  Trips5
//
//  Created by Rob Goble on 2/5/23.
//

import SwiftUI

struct GaugeData: Identifiable, Hashable {
    let id = UUID()
    var value: Double
    var min: Double
    var max: Double
    var text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func mpgGauge() -> GaugeData {
        return GaugeData(value: 0, min: 0, max: 50, text: "")
    }
    
    static func distanceGauge() -> GaugeData {
        return GaugeData(value: 0, min: 0, max: 5000, text: "")
    }
}

struct GaugeView: View {
    var data: GaugeData
    
    var body: some View {
        Gauge(value: data.value, in: data.min...data.max) {
            Text(data.text)
        } currentValueLabel: {
            Text(data.value.formatted())
        }
        .tint(.blue)
        .gaugeStyle(.accessoryCircular)
        .padding(EdgeInsets(top: 6.0, leading: 0, bottom: 0, trailing: 0))
    }
}
