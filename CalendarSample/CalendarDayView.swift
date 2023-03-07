//
//  CalendarDayView.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import UIKit
import Cartography

class CalendarDayView: UIView {

    var labelDay: UILabel?
    var stackViewEvents: UIStackView?
    var button: UIButton?
    var constraintEventsHeight: NSLayoutConstraint?
    
    var data: CalendarDayObject?
    var callbackOnClick: ((Date?) -> Void)?
    var delegate: CalendarProtocol?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    init(delegate: CalendarProtocol?) {
        super.init(frame: .zero)
        self.delegate = delegate
        initialize()
    }
    
    func initialize() {
        if self.delegate?.type() != .onlyMonth {
            self.stackViewEvents = UIStackView(frame: .zero)
            self.addSubview(self.stackViewEvents!)
            
            Cartography.constrain(self.stackViewEvents!) { (stack) in
                stack.trailing == stack.superview!.trailing
                stack.leading == stack.superview!.leading
                stack.bottom == stack.superview!.bottom
            }
            
            self.stackViewEvents?.distribution = .fillEqually
            self.stackViewEvents?.alignment = .center
            self.stackViewEvents?.axis = .vertical
        }
        
        self.labelDay = UILabel(frame: .zero)
        self.labelDay?.font = UIFont.systemFont(ofSize: 12.0)
        self.labelDay?.textColor = .black
        self.labelDay?.textAlignment = .center
        self.labelDay?.backgroundColor = .clear
        self.addSubview(self.labelDay!)
        
        Cartography.constrain(self.labelDay!) { (label) in
            if self.delegate?.type() == .onlyMonth {
                label.center == label.superview!.center
                label.width == 20.0
            } else {
                label.top == label.superview!.top
                label.trailing == label.superview!.trailing
                label.leading == label.superview!.leading
            }
            label.height == 20.0
        }
        
        self.button = UIButton(frame: .zero)
        self.addSubview(self.button!)
        
        Cartography.constrain(self.button!) { (btn) in
            btn.top == btn.superview!.top
            btn.leading == btn.superview!.leading
            btn.trailing == btn.superview!.trailing
            btn.bottom == btn.superview!.bottom
        }
        
        self.button?.setTitle("", for: .normal)
        self.button?.addTarget(self, action: #selector(onSelect), for: .touchUpInside)
    }
    
    func setup(delegate: CalendarProtocol?, data: CalendarDayObject?, cellHeight: CGFloat, callbackOnClick: ((Date?) -> Void)? ) {
        self.callbackOnClick = callbackOnClick
//        self.button.setTitle("", for: .normal)
        self.data = data
        self.delegate = delegate
        
        self.labelDay?.text = data?.day() ?? ""
        if self.delegate?.type() == .onlyMonth {
            self.labelDay?.layer.cornerRadius = 10.0
            self.labelDay?.layer.masksToBounds = true
        }
//        self.constraintEventsHeight.constant = cellHeight - labelDay.font.lineHeight
        let isSelect = self.delegate?.selectedDate().isSameDate(date: data?.date) ?? false
        
        setSelectDay(isSelect: isSelect)
        
    }
    
    @objc func onSelect(_ sender: Any) {
        if let date = self.data?.date, self.data?.isEnable == true {
            self.callbackOnClick?(date)
        }
    }
    
    func isToday() -> Bool {
        return data?.date?.isSameDate(date: Date()) ?? false
    }
    
    func setSelectDay(isSelect: Bool) {
        let enableTextColor: UIColor = .black
        let disableTextColor: UIColor = .black.withAlphaComponent(0.5)
        let todayTextColor: UIColor = .black
        let todayBackgroundColor: UIColor = .green
        let backgroundColor: UIColor = .white
        let selectColor: UIColor = .red
        
        if self.data?.isEnable == true {
            labelDay?.textColor = enableTextColor
            if isSelect {
                if self.delegate?.type() == .onlyMonth {
                    self.labelDay?.backgroundColor = selectColor
                } else {
                    self.backgroundColor = selectColor
                    self.labelDay?.backgroundColor = selectColor
                }
            } else {
                if isToday() {
                    self.labelDay?.textColor = todayTextColor
                    if self.delegate?.type() == .onlyMonth {
                        self.labelDay?.backgroundColor = todayBackgroundColor
                    } else {
                        self.backgroundColor = todayBackgroundColor
                        self.labelDay?.backgroundColor = todayBackgroundColor
                    }
                } else {
                    self.backgroundColor = backgroundColor
                    self.labelDay?.backgroundColor = backgroundColor
                }
            }
        } else {
            self.labelDay?.textColor = disableTextColor
            self.backgroundColor = backgroundColor
            self.labelDay?.backgroundColor = backgroundColor
        }
    }
    
}
