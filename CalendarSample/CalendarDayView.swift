//
//  CalendarDayView.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import UIKit
import RxCocoa

class CalendarDayView: UIView {

    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var stackViewEvents: UIStackView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var constraintEventsHeight: NSLayoutConstraint!
    var data: CalendarDayObject?
    var callbackOnClick:((Date?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        if self.subviews.count == 0, let view = Bundle.main.loadNibNamed("\(CalendarDayView.self)", owner: self)?.first as? UIView {
            self.addSubview(view)
            view.frame = self.bounds
        }
    }
    
    func setup(selectDate: Date?, data: CalendarDayObject?, cellHeight: CGFloat, callbackOnClick:((Date?) -> Void)? ) {
        self.callbackOnClick = callbackOnClick
        self.button.setTitle("", for: .normal)
        self.data = data
        
        labelDay.text = data?.day() ?? ""
        self.constraintEventsHeight.constant = cellHeight - labelDay.font.lineHeight
        let isSelect = selectDate?.isSameDate(date: data?.date) ?? false
        
        setSelectDay(isSelect: isSelect)
        
    }
    
    @IBAction func onSelect(_ sender: Any) {
        if let date = self.data?.date, self.data?.isEnable == true {
            self.callbackOnClick?(date)
        }
    }
    
    func isToday() -> Bool {
        return data?.date?.isSameDate(date: Date()) ?? false
    }
    
    func setSelectDay(isSelect: Bool) {
        if self.data?.isEnable == true {
            labelDay.textColor = .black
            if isSelect {
                self.backgroundColor = .red
            } else {
                if isToday() {
                    self.backgroundColor = .green
                } else {
                    self.backgroundColor = .clear
                }
            }
        } else {
            labelDay.textColor = .black.withAlphaComponent(0.5)
            self.backgroundColor = .clear
        }
    }
    
}
