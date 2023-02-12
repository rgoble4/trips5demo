//
//  VehicleFormView.swift
//  Trips5
//
//  Created by Rob Goble on 8/14/22.
//

import SwiftUI

struct VehicleFormView: View {
    
    @State
    var vehicle: Vehicle
    
    @FocusState
    private var focusedField: FocusField?
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.dependencies)
    private var dependencies
    
    enum FocusField: Hashable {
        case field
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("")) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Name").font(Font.caption2).foregroundColor(Color(uiColor: dependencies.theme.tintColor))
                        TextField("", text: $vehicle.name)
                            .focused($focusedField, equals: .field)
                            .task {
                                self.focusedField = .field
                            }
                    }
                }
                Section(header: Text("Actions")) {
                    Button(action: {
                        Task {
                            await dependencies.vehicleStore.delete(vehicle)
                        }
                        dismiss()
                    }, label: {
                        Text("Delete").foregroundColor(Color.red)
                    })
                    .accessibilityIdentifier("vehicleDeleteButton")
                    .accessibilityLabel("Delete Vehicle")
                }
            }
            .navigationTitle("Vehicle").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await dependencies.vehicleStore.upsert(vehicle)
                        }
                        dismiss()
                    }, label: {
                        Text("Save")
                    })
                    .accessibilityIdentifier("vehicleSaveButton")
                    .accessibilityLabel("Save Fuel")
                }
            }
        }
    }
}
