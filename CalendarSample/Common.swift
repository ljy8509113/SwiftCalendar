//
//  Common.swift
//  CalendarSample
//
//  Created by jeong lee on 2023/02/17.
//

import Foundation

enum CalendarScope {
    case month
    case week
    case changing
}

enum AnimationState {
    case wait
    case animating
    case end
}

protocol CalendarDelegate {
    func changeHeight(height: CGFloat)
    func changeWeek(date: Date)
    func selectDate(date: Date)
    func selectedDate() -> Date
    func scope() -> CalendarScope
}

class Common: NSObject {
    static let CELL_HEIGHT = 60.0
    static let TOP_HEIGHT = 90.0
}
