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
                    FormRow(label: "Name") {
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
                FormToolbar(canSave: true) {
                    Task {
                        await dependencies.vehicleStore.upsert(vehicle)
                    }
                    dismiss()
                }
            }
        }
    }
}
