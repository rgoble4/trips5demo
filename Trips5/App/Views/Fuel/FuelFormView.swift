//
//  FuelFormView.swift
//  Trips5
//
//  Created by Rob Goble on 9/15/22.
//

import SwiftUI

struct FuelFormView: View {
    
    @ObservedObject
    var viewModel: FuelFormViewModel
    
    @State
    var date: Date = Date()
    
    @FocusState
    private var focusedField: FocusField?
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.dependencies)
    private var dependencies
    
    enum FocusField: Hashable {
        case fromOdo, toOdo, fuelAmt
        
        var next: FocusField {
            switch self {
            case .fuelAmt: return .fromOdo
            case .fromOdo: return .toOdo
            case .toOdo: return .fuelAmt
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("")) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Date")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: dependencies.theme.tintColor))
                        DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                    }
                }
                Section(header: Text("")) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("From")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: dependencies.theme.tintColor))
                        TextField("", text: $viewModel.fromOdo)
                            .focused($focusedField, equals: .fromOdo)
                            .keyboardType(.numberPad)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("To")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: dependencies.theme.tintColor))
                        TextField("", text: $viewModel.toOdo)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .toOdo)
                            .task {
                                focusedField = .toOdo
                            }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fuel Amount")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: dependencies.theme.tintColor))
                        TextField("", text: $viewModel.fuelAmount)
                            .focused($focusedField, equals: .fuelAmt)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.fuelAmount, perform: { newValue in
                                let toOperateOn = newValue.replacingOccurrences(of: ".", with: "")
                                
                                if let dbl = Double(toOperateOn) {
                                    if dbl == 0 {
                                        viewModel.fuelAmount = ""
                                    } else {
                                        viewModel.fuelAmount = String(format: "%.3f", arguments: [dbl / 1000])
                                    }
                                } else {
                                    viewModel.fuelAmount = ""
                                }
                            })
                    }
                }
                Section(header: Text("")) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Distance")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: UIColor.label))
                        Text("\(viewModel.distance)")
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MPG")
                            .font(Font.caption2)
                            .foregroundColor(Color(uiColor: UIColor.label))
                        Text(viewModel.mpg)
                    }
                }
                Section(header: Text("Actions")) {
                    Button(action: {
                        Task {
                            await dependencies.fuelStore.delete(viewModel.asVehicleFuel)
                        }
                        dismiss()
                    }, label: {
                        Text("Delete").foregroundColor(Color.red)
                    })
                    .accessibilityIdentifier("fuelDeleteButton")
                    .accessibilityLabel("Delete Fuel")
                }
            }
            .navigationTitle("Fuel Entry").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await dependencies.fuelStore.upsert(viewModel.asVehicleFuel)
                        }
                        dismiss()
                    }, label: {
                        Text("Save")
                    })
                    .accessibilityIdentifier("fuelSaveButton")
                    .accessibilityLabel("Save Fuel")
                    .disabled(!viewModel.canSave)
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Next") {
                        focusedField = focusedField?.next
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
}
