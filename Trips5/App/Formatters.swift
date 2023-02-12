//
//  Formatters.swift
//  Trips5
//
//  Created by Rob Goble on 9/7/22.
//

import Foundation

struct Formatter {
    let dayMonthOnly = DateFormatter()
    let fullDateFormatter = DateFormatter()
    let monthYearFormatter = DateFormatter()
    let monthYearSortFormatter = DateFormatter()
    let noTimeFormatter = DateFormatter()
    let yearFormatter = DateFormatter()
    
    static let shared = Formatter()
    
    private init() {
        dayMonthOnly.dateFormat = "MMMM d"
        fullDateFormatter.dateStyle = .medium
        fullDateFormatter.timeStyle = .short
        monthYearFormatter.dateFormat = "MMM yyyy"
        monthYearSortFormatter.dateFormat = "yyyy-MM"
        noTimeFormatter.dateFormat = "yyyy-MM-dd"
        yearFormatter.dateFormat = "yyyy"
    }
    
    func round1(_ double: Double) -> Double {
        return round(double * 10) / 10
    }
    
    func round2(_ double: Double) -> Double {
        return round(double * 100) / 100
    }
    
    func round2Str(_ double: Double) -> String {
        return String(format: "%.2f", arguments: [round2(double)])
    }
}
