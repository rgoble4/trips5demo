//
//  FormRow.swift
//  Trips5
//
//  Created by Rob Goble on 2/18/23.
//

import SwiftUI

struct FormRow<FormField: View>: View {
    var label: String
    
    @ViewBuilder
    var formField: () -> FormField
    
    @Environment(\.dependencies)
    private var dependencies
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Font.caption2)
                .foregroundColor(Color(uiColor: dependencies.theme.tintColor))
            formField()
        }
    }
}
