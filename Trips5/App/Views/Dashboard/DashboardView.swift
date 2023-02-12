//
//  DashboardView.swift
//  Trips5
//
//  Created by Rob Goble on 2/4/23.
//

import SwiftUI

struct DashboardView: View {
    typealias Dependencies =
        DatabaseProvider &
        FormatterProvider &
        FuelStoreProvider &
        TripStoreProvider &
        VehicleStoreProvider
    
    @ObservedObject
    private var viewModel: DashboardViewModel
    
    private let dependencies: Dependencies
    private var formatter: Formatter
    private var vehicleStore: VehicleStore
    
    private let valueColumns = [
        GridItem(.fixed(80))
    ]
    
    private let graphColumns = [
        GridItem(.adaptive(minimum: 280))
    ]
    
    init(_ dependencies: Dependencies) {
        viewModel = DashboardViewModel(dependencies)
        self.dependencies = dependencies
        self.formatter = dependencies.formatter
        self.vehicleStore = dependencies.vehicleStore
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        ForEach(viewModel.gauges, id: \.self) { gauge in
                            GaugeGroupView(gaugeGroup: gauge)
                        }
                    }
                    ScrollView {
                        LazyVGrid(columns: graphColumns) {
                            ForEach(viewModel.graphs, id: \.self) { graph in
                                CardView {
                                    LineGraphView(data: graph).padding(12.0)
                                }.frame(minWidth: 180, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                            }
                        }
                    }
                }.padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    ButtonBarView(dependencies)
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color(white: 0, opacity: 0.75)
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                }
            }
        }
    }
}
