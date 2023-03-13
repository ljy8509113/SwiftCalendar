//
//  CalendarDateHeaderView.swift
//  CalendarSample
//
//  Created by Murf on 2023/03/13.
//

import UIKit
import Cartography

class CalendarDayHeaderView: UIStackView {
    var arrayWeekStr: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        self.backgroundColor = .clear
        self.axis = .horizontal
        self.spacing = 0.0
        self.alignment = .fill
        self.distribution = .fillEqually
        
        for i in 0...6 {
            let label = UILabel(frame: .zero)
            label.textColor = .white
            label.font = .systemFont(ofSize: 11.0, weight: .bold)
            label.tag = i
            label.textAlignment = .center
            
            self.addArrangedSubview(label)
        }
    }
    
    func setup(weeks: [Date]?) {
        if let dates = weeks {
            for date in dates {
                arrayWeekStr.append(Calendar.current.dayStr(date: date))
            }
        } else {
            arrayWeekStr = ["일", "월", "화", "수", "목", "금", "토"]
        }
        
        self.subviews.enumerated().forEach({
            if let label = $0.element as? UILabel {
                let dayStr = arrayWeekStr[$0.offset]
                label.text = dayStr
                if dayStr == "일" {
                    label.textColor = .red // e86e6e
                } else if dayStr == "토" {
                    label.textColor = .blue // 95a4db
                } else {
                    label.textColor = .white
                }
            }
        })
        
    }
    
    
}
