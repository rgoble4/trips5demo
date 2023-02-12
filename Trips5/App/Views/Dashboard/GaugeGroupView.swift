//
//  GaugeGroupView.swift
//  Trips5
//
//  Created by Rob Goble on 2/10/23.
//

import SwiftUI

struct GaugeGroupData: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var gauges: [GaugeData]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct GaugeGroupView: View {
    var gaugeGroup: GaugeGroupData
    
    var body: some View {
        VStack(spacing: 8) {
            CardView {
                Text(gaugeGroup.title)
            }
            HStack {
                ForEach(gaugeGroup.gauges, id: \.self) { gauge in
                    CardView {
                        GaugeView(data: gauge)
                    }
                }
            }
        }
    }
}
