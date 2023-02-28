//
//  CalendarMonthObject.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import Foundation

class CalendarMonthObject: NSObject {
    var date: Date = Date()
    var calendar = Calendar.current
    
    var arrayWeek: [CalendarWeekObject] = []
    
    init(date: Date = Date()) {
        super.init()
        self.date = date
        
        updateDays()
    }
    
//    func startDayOfWeek() -> Int {
//        let year = calendar.component(.year, from: self.date)
//        let month = calendar.component(.month, from: self.date)
//        let firstDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
//        return self.calendar.component(.weekday, from: firstDate) - 1
//    }
//
//    func endDate() -> Int? {
//        return self.calendar.range(of: .day, in: .month, for: self.date)?.count
//    }
    
    func updateDays() {
//        self.arrayWeek.removeAll()
        let start = self.calendar.startDayOfWeek(date: self.date)
        let end = self.calendar.endDate(date: self.date) ?? 0
        let monthEnd = end + start
        var rows = monthEnd / 7
        if monthEnd % 7 > 0 {
            rows += 1
        }
//        let total = rows * 7
        
        print("updateDays : \(self.date)")
        
        for i in 0..<rows {
            var array: [CalendarDayObject] = []
            for j in 0...6 {
                let index = i * 7 + j
                var date: Date
                var day: Int
                var isEnable: Bool = false
                
                if index < start {
                    date = calendar.date(byAdding: DateComponents(month: -1), to: self.date) ?? Date()
                    let lastDay = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
                    day = lastDay - (start - (index + 1))
                } else {
                    if monthEnd <= index {
                        date = calendar.date(byAdding: DateComponents(month: 1), to: self.date) ?? Date()
                        day = index - (monthEnd - 1)
                    } else {
                        date = self.date
                        day = index - start + 1
                        isEnable = true
                    }
                }
                
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                
                let makeDate = calendar.date(from: DateComponents(year: year, month: month, day: day))
                let obj = CalendarDayObject(date: makeDate, events: [], isEnable: isEnable)
                array.append(obj)
            }
            
            
            let week = CalendarWeekObject(date: array.first?.date ?? Date(), array: array)
            self.arrayWeek.append(week)
        }
    }
}
