//
//  CalendarHeaderReusableView.swift
//  CalendarSample
//
//  Created by jeong lee on 2023/03/01.
//

import UIKit

class CalendarHeaderReusableView: UICollectionReusableView {

    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var labelMonth: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    var callbackMove: ((Bool) -> Void)?
    var formatter: DateFormatter = DateFormatter()
    var date: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.formatter.dateFormat = "yyyyMM"
        let arrayWeekStr = ["일", "월", "화", "수", "목", "금", "토"]
        for day in arrayWeekStr {
            let label = UILabel(frame: .zero)
            label.text = day
            label.textAlignment = .center
            label.textColor = .black
            self.stackView.addArrangedSubview(label)
        }
    }
    
    func setup(date: Date, callbackMove: ((Bool) -> Void)?) {
        self.callbackMove = callbackMove
        update(date: date)
    }
    
    func update(date: Date) {
        if date.isSameMonth(date: self.date) == false {
            self.date = date
            self.labelMonth.text = formatter.string(from: date)
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        self.callbackMove?(true)
    }
    
    @IBAction func onPrevioues(_ sender: Any) {
        self.callbackMove?(false)
    }
    
}
