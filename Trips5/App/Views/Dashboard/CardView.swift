//
//  CardView.swift
//  Trips5
//
//  Created by Rob Goble on 2/5/23.
//

import SwiftUI

struct CardView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(uiColor: UIColor.secondarySystemFill))
            content//.padding(Constants.listInsets)
        }
    }
}
