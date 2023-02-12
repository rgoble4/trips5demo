//
//  NoDataView.swift
//  Trips5
//
//  Created by Rob Goble on 2/11/23.
//

import SwiftUI

struct NoDataView: View {
    var body: some View {
        Text("No Available Vehicle. Please make sure you have at least one vehicle defined in Settings.")
            .accessibilityIdentifier("noDataText")
    }
}
