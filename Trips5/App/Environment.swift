//
//  Environment.swift
//  Trips5
//
//  Created by Rob Goble on 8/14/22.
//

import Foundation
import SwiftUI

private let HostKey = "ActiveEnvironmentKey"

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue = DependencyManager()
}

extension EnvironmentValues {
    var dependencies: DependencyManager {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

class Env: ObservableObject {
    static let shared = Env()
    
    @Published
    private (set) var host: Host = .remote
    
    private init() {
        if let activeEnv = UserDefaults.standard.string(forKey: HostKey),
           let env = Host(rawValue: activeEnv) {
        
            host = env
        }
    }
    
    func setEnv(to host: Host) {
        UserDefaults.standard.set(host.rawValue, forKey: HostKey)
        self.host = host
    }
}

enum Host: String, CaseIterable {
    case local, none, remote
    
    var base: URL? {
        switch self {
        case .none: return nil
        case .local: return URL(string: "http://0.0.0.0:12002")
        case .remote: return URL(string: "https://api.rg4dev.com:12003")
        }
    }
}

enum RequestType {
    case getAll, getById, post
}

protocol URLPathProviding {
    static func url(for requestType: RequestType) -> URL?
}
