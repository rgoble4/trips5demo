//
//  FormToolbar.swift
//  Trips5
//
//  Created by Rob Goble on 2/18/23.
//

import SwiftUI

struct FormToolbar: ToolbarContent {
    var canSave: Bool = false
    var doneAction: (() -> Void)?
    var nextAction: (() -> Void)?
    var saveAction: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: saveAction, label: {
                Text("Save")
            })
            .accessibilityIdentifier("saveButton")
            .accessibilityLabel("Save")
            .disabled(!canSave)
        }
        if let nextAction {
            ToolbarItem(placement: .keyboard) {
                Button(action: nextAction, label: {
                    Text("Next")
                })
                .accessibilityIdentifier("nextButton")
                .accessibilityLabel("Next")
            }
        }
        if let doneAction {
            ToolbarItem(placement: .keyboard) {
                Button(action: doneAction, label: {
                    Text("Done")
                })
                .accessibilityIdentifier("doneButton")
                .accessibilityLabel("Done")
            }
        }
    }
}
