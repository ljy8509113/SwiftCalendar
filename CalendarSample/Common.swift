//
//  Common.swift
//  CalendarSample
//
//  Created by jeong lee on 2023/02/17.
//

import Foundation

enum CalendarStatus {
    case month
    case week
    case changing
}

enum CalendarMoveType {
    case today
    case previous
    case next
}

enum CalendarType {
    case onlyMonth
    case onlyWeek
    case monthAndWeek
}

protocol CalendarDelegate {
    func changeHeight(height: CGFloat)
    func changeWeek(date: Date)
    func selectDate(date: Date)
    func selectedDate() -> Date
    func status() -> CalendarStatus
}

class Common: NSObject {
    static let CELL_HEIGHT = 60.0
}
