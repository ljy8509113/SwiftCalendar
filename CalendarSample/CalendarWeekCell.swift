//
//  CalendarWeekCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import UIKit
import Cartography

class CalendarWeekCell: UICollectionViewCell {
    var dayHeaderView: CalendarDayHeaderView?
    var stackView: UIStackView?
    var arrayDays: [CalendarDayObject] = []
    var callbackOnClick: ((Date?) -> Void)?
    var delegate: CalendarProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initialize(type: CalendarType?) {
        if type == .onlyWeek, self.dayHeaderView == nil {
            self.dayHeaderView = CalendarDayHeaderView()
            self.contentView.addSubview(self.dayHeaderView!)
            
            Cartography.constrain(self.dayHeaderView!) { (stack) in
                stack.top == stack.superview!.top
                stack.trailing == stack.superview!.trailing
                stack.leading == stack.superview!.leading
                stack.height == 30.0
            }
        }
        
        if self.stackView == nil {
            self.backgroundColor = .clear
            
            self.stackView = UIStackView(frame: .zero)
            self.stackView?.backgroundColor = .clear
            self.stackView?.axis = .horizontal
            self.stackView?.alignment = .fill
            self.stackView?.spacing = 0.0
            self.stackView?.distribution = .fillEqually
            self.contentView.addSubview(self.stackView!)
            
            let topView = self.dayHeaderView ?? self.contentView
            
            Cartography.constrain(self.stackView!, topView) { (v, topView) in
                v.leading == v.superview!.leading
                v.trailing == v.superview!.trailing
                if type == .onlyWeek {
                    v.top == topView.bottom
                } else {
                    v.top == v.superview!.top
                }
                v.bottom == v.superview!.bottom
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(delegate: CalendarProtocol?, array: [CalendarDayObject], cellHeight: CGFloat, callbackOnClick: ((Date?) -> Void)? ) {
        self.arrayDays = array
        self.delegate = delegate
        
        initialize(type: self.delegate?.type())
        if let header = self.dayHeaderView {
            let weeks = array.map({ (obj) -> Date in
                return obj.date ?? Date()
            })
            header.setup(weeks: weeks)
        }
        
        var subCount = self.stackView?.subviews.count ?? 0
        
        if subCount < 7 {
            self.stackView?.subviews.forEach {
                $0.removeFromSuperview()
            }
            
            for i in 1...7 {
                let view = CalendarDayView(delegate: self.delegate)
                view.tag = i
                self.stackView?.addArrangedSubview(view)
            }
        }
        
        subCount = self.stackView?.subviews.count ?? 0
        for i in 0..<array.count {
            if subCount > i, let view = self.stackView?.subviews[i] as? CalendarDayView {
//                view.setup(data: array[i], cellHeight: cellHeight,  delegate: delegate)
                view.setup(delegate: self.delegate, data: array[i], cellHeight: cellHeight, callbackOnClick: callbackOnClick)
            }
        }
    }
    
    func setSelectDay(date: Date?) {
        self.stackView?.subviews.forEach({
            if let view = $0 as? CalendarDayView {
                view.setSelectDay(isSelect: date?.isSameDate(date: view.data?.date) == true)
            }
        })
    }
    
    func exitsDate(date: Date?) -> Bool {
        return self.stackView?.subviews.first(where: { ($0 as? CalendarDayView)?.data?.date?.isSameDate(date: date) == true }) != nil
    }
    
    func changeAlpha(alpha: CGFloat) {
        self.stackView?.alpha = alpha
    }
}
