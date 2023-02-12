//
//  Constants.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Foundation
import SwiftUI

struct Constants {
    static let pageSize = 100
    
    static let listInsets = EdgeInsets(top: 4,
                                       leading: 16,
                                       bottom: 4,
                                       trailing: 16)
    
    /// Returns the build date of the app.
    static var buildDate: Date {
        if let executablePath = Bundle.main.executablePath,
            let attributes = try? FileManager.default.attributesOfItem(atPath: executablePath),
            let date = attributes[.creationDate] as? Date
        {
            return date
        }
        return Date()
    }
    
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: (kCFBundleVersionKey as String)) as! String
    }
    
    static var versionBuild: String {
        return appVersion == appBuild ? "v\(appVersion)" : "v\(appVersion) (\(appBuild))"
    }
}
