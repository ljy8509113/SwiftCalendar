//
//  CalendarMonthObject.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import Foundation

class CalendarMonthObject: NSObject {
    var startDate: Date?
    var date: Date = Date()
    var calendar = Calendar.current
    
    var arrayWeek: [CalendarWeekObject] = []
    var formatter = DateFormatter()
    
    init(date: Date = Date(), startDate: Date?) {
        super.init()
        self.date = date
        self.startDate = startDate
        self.formatter.dateFormat = "yyyyMMdd"
        updateDays()
    }
    
    func updateDays() {
//        self.arrayWeek.removeAll()
        let start = self.calendar.startIndexOfMonth(date: self.date)
        let end = self.calendar.endDate(date: self.date) ?? 0
        let monthEnd = end + start
        var rows = monthEnd / 7
        if monthEnd % 7 > 0 {
            rows += 1
        }
        
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
                
                if let startDate = self.startDate {
                    let s = Int(self.formatter.string(from: startDate)) ?? 0
                    let cur = Int(self.formatter.string(from: makeDate ?? Date())) ?? 0
                    isEnable = s <= cur
                }
                
                let obj = CalendarDayObject(date: makeDate, events: [], isEnable: isEnable)
                array.append(obj)
            }
            
            
            let week = CalendarWeekObject(date: array.first?.date ?? Date(), array: array)
            self.arrayWeek.append(week)
        }
    }
}
