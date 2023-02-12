//
//  Extensions.swift
//  Trips5
//
//  Created by Rob Goble on 9/5/22.
//

import Foundation

extension Date {
    
    // MARK: Properties
    
    var startOfMonth: Date {
        let cal = Calendar.current
        let currentDateComponents = cal.dateComponents([.year, .month], from: self)
        let startOfMonth = cal.date(from: currentDateComponents)
        
        guard let date = startOfMonth else { fatalError("Couldn't Create Date") }
        
        return date
    }
    
    var startOfYear: Date {
        let cal = Calendar.current
        let currentDateComponents = cal.dateComponents([.year], from: self)
        let startOfYear = cal.date(from: currentDateComponents)
        
        guard let date = startOfYear else { fatalError("Couldn't Create Date") }
        
        return date
    }
    
    var isSameMonthAsToday: Bool {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        
        let now = Date()
        let nowComponents = DateComponents(year: calendar.component(.year, from: now), month: calendar.component(.month, from: now))
        
        return dateComponents.year == nowComponents.year && dateComponents.month == nowComponents.month
    }
    
    var numberOfDaysInMonth: Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let firstDate = calendar.date(from: dateComponents)!
        return calendar.range(of: .day, in: .month, for: firstDate)!.count
    }
    
    var dayInMonth: Int {
        let components = Calendar.current.dateComponents([.day], from: self)
        return components.day!
    }
    
    // MARK: Instance helpers
    
    func withoutTime() -> Date? {
        let cal = Calendar.current

        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0

        return cal.date(from: components)
    }
    
    // MARK: Static helpers
    
    static func monthsAgo(_ months: Int) -> Date {
        let cal = Calendar.current
        var components = DateComponents()
        components.month = -months
        
        guard let date = cal.date(byAdding: components, to: .now) else { fatalError("Couldn't create date") }
        
        return date
    }
    
    static func yearsAgo(_ years: Int) -> Date {
        let cal = Calendar.current
        var components = DateComponents()
        components.year = -years
        
        guard let date = cal.date(byAdding: components, to: .now) else { fatalError("Couldn't create date") }
        
        return date
    }
}
