//
//  CardView.swift
//  Trips5
//
//  Created by Rob Goble on 2/5/23.
//

import SwiftUI

struct CardView<Content: View>: View {
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(uiColor: UIColor.secondarySystemFill))
            content()
        }
    }
}
