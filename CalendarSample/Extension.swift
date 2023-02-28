//
//  Extension.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/15.
//

import UIKit

extension UICollectionView {
    func registerNib<T>(type: T.Type) {
        let name = String(describing: type)
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: "\(T.self)")
    }
    
    func dequeueReusableCell<T>(type: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
}

extension UICollectionViewCell {
    @objc
    class func getSize(data: Any? = nil, width: CGFloat = UIScreen.main.bounds.size.width) -> CGSize {
        if let nib = loadNib(type: self) {
            var frame = nib.frame
            frame.size.width = width
            nib.frame = frame
            
            return nib.systemLayoutSizeFitting(nib.frame.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        } else {
            return .zero
        }
    }
}

extension UIView {
    class func loadNib<T>(type: T.Type) -> T? {
        let name = String(describing: type)
        if let view: UIView = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView {
            return view as? T
        } else {
            return nil
        }
    }
}


extension Date {
    func isSameDate(date: Date?) -> Bool {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            
            let current = formatter.string(from: self)
            let target = formatter.string(from: date)
            
            return current == target
        }
        return false
    }
    
    func isSameMonth(date: Date?) -> Bool {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMM"
            
            let current = formatter.string(from: self)
            let target = formatter.string(from: date)
            
            return current == target
        }
        return false
    }
}

extension Calendar {
    func getMonthOfWeekCount(date: Date) -> Int {
        let start = startDayOfWeek(date: date)
        let end = endDate(date: date) ?? 0
        let monthEnd = end + start
        var rows = monthEnd / 7
        if monthEnd % 7 > 0 {
            rows += 1
        }
        if rows < 4 {
            return 5
        }
        return rows
    }
    
    func startDayOfWeek(date: Date) -> Int {
        let year = self.component(.year, from: date)
        let month = self.component(.month, from: date)
        let firstDate = self.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        return self.component(.weekday, from: firstDate) - 1
    }
    
    func endDate(date: Date) -> Int? {
        return self.range(of: .day, in: .month, for: date)?.count
    }
}
