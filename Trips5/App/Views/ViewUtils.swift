//
//  ViewUtils.swift
//  Trips5
//
//  Created by Rob Goble on 9/19/22.
//

import Foundation
import UIKit

struct ViewUtils {
    
    @MainActor
    static func presentError(_ error: Error) {
//        if let error = error as? URLError,
//           error.errorCode == -1009 {
//
//            // Offline, skip
//            return
//        }
        
        let action = UIAlertAction(title: "OK", style: .default)
        
        let dialogMessage = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        dialogMessage.addAction(action)
        
        if let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
            
            keyWindow.rootViewController?.present(dialogMessage, animated: true)
        }
    }
}
