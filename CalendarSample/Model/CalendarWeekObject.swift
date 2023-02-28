//
//  CalendarWeekObject.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import Foundation

class CalendarWeekObject: NSObject {
    var date: Date?
    var calendar = Calendar.current
    
    var arrayDays: [CalendarDayObject] = []
    
    init(date: Date?, array: [CalendarDayObject]?) {
        super.init()
        self.date = date
        
        if let days = array {
            self.arrayDays = days
        } else {
            updateDays()
        }
    }
    
    func update(date: Date?) {
        if let d = date {
            self.date = d
            updateDays()
        }
    }
    
    func updateDays() {
        self.arrayDays.removeAll()
        
        for i in 0...6 {
            let date = self.calendar.date(byAdding: .day, value: i, to: self.date ?? Date()) ?? Date()
            let obj = CalendarDayObject(date: date, events: [], isEnable: true)
            self.arrayDays.append(obj)
        }
    }
}
