//
//  CalendarDayObject.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/15.
//

import UIKit

class CalendarDayObject: NSObject {
    var date: Date?
    var isEnable: Bool = true
    var events: [String]?
    
    init(date: Date?, events: [String], isEnable: Bool) {
        self.date = date
        self.isEnable = isEnable
    }
    
    func day() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let dayStr = formatter.string(from: self.date ?? Date())
        
        if let day = Int(dayStr) {
            return "\(day)"
        } else {
            return ""
        }
    }
}
