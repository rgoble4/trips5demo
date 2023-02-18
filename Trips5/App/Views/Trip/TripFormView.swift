//
//  TripFormView.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import SwiftUI

struct TripFormView: View {
    
    @ObservedObject
    var viewModel: TripFormViewModel
    
    @State
    var date: Date = Date()
    
    @FocusState
    private var focusedField: FocusField?
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.dependencies)
    private var dependencies
    
    enum FocusField: Hashable {
        case fromOdo, toOdo
        
        var next: FocusField {
            switch self {
            case .fromOdo: return .toOdo
            case .toOdo: return .fromOdo
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("")) {
                    FormRow(label: "Date") {
                        DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                    }
                }
                Section(header: Text("")) {
                    FormRow(label: "From") {
                        TextField("", text: $viewModel.fromOdo)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .fromOdo)
                    }
                    FormRow(label: "To") {
                        TextField("", text: $viewModel.toOdo)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .toOdo)
                            .task {
                                focusedField = .toOdo
                            }
                    }
                }
                Section(header: Text("")) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Distance")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: UIColor.label))
                        Text("\(viewModel.distance)")
                    }
                }
                Section(header: Text("Actions")) {
                    Button(action: {
                        Task {
                            await dependencies.tripStore.delete(viewModel.asVehicleTrip)
                        }
                        dismiss()
                    }, label: {
                        Text("Delete").foregroundColor(Color.red)
                    })
                    .accessibilityIdentifier("tripDeleteButton")
                    .accessibilityLabel("Delete Trip")
                }
            }
            .navigationTitle("Trip").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar(canSave: viewModel.canSave, doneAction: {
                    focusedField = nil
                }, nextAction: {
                    focusedField = focusedField?.next
                }) {
                    Task {
                        await dependencies.tripStore.upsert(viewModel.asVehicleTrip)
                    }
                    dismiss()
                }
            }
        }
    }
}
