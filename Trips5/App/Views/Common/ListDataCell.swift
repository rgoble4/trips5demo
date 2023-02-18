//
//  ListDataCell.swift
//  Trips5
//
//  Created by Rob Goble on 2/18/23.
//

import SwiftUI

struct ListDataCell: View {
    var leftText: String
    var rightTopText: String
    var rightBottomText: String
    var showSyncIcon: Bool
    
    @Environment(\.dependencies) var dependencies
    
    var body: some View {
        HStack {
            Text(leftText)
                .foregroundColor(Color(uiColor: dependencies.theme.primaryTextColor))
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(rightTopText).font(Font.footnote)
                    .foregroundColor(Color(uiColor: dependencies.theme.primaryTextColor))
                Text(rightBottomText).font(Font.footnote)
                    .foregroundColor(Color(uiColor: dependencies.theme.primaryTextColor))
            }
            if showSyncIcon {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(Color(uiColor: dependencies.theme.tintColor))
            }
        }
    }
}
