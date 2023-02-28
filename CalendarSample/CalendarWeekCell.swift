//
//  CalendarWeekCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import UIKit
import RxCocoa


class CalendarWeekCell: UICollectionViewCell {

    @IBOutlet weak var stackView: UIStackView!
    var arrayDays: [CalendarDayObject] = []
    var callbackOnClick: ((Date?) -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.backgroundColor = .gray
        for i in 1...7 {
            let view = CalendarDayView(frame: .zero)
            view.tag = i
            self.stackView.addArrangedSubview(view)
        }
    }
    
    func setup(selectDate: Date?, array: [CalendarDayObject], cellHeight: CGFloat, callbackOnClick: ((Date?) -> Void)? ) {
        self.arrayDays = array
        let subCount = self.stackView.subviews.count
        
        for i in 0..<array.count {
            if subCount > i, let view = self.stackView.subviews[i] as? CalendarDayView {
//                view.setup(data: array[i], cellHeight: cellHeight,  delegate: delegate)
                view.setup(selectDate: selectDate, data: array[i], cellHeight: cellHeight, callbackOnClick: callbackOnClick)
            }
        }
    }
    
    func setSelectDay(date: Date?) {
        self.stackView.subviews.forEach({
            if let view = $0 as? CalendarDayView {
                view.setSelectDay(isSelect: date?.isSameDate(date: view.data?.date) == true)
            }
        })
    }
    
    func exitsDate(date: Date?) -> Bool {
        return self.stackView.subviews.first(where: { ($0 as? CalendarDayView)?.data?.date?.isSameDate(date: date) == true }) != nil
    }
    
    func changeAlpha(alpha: CGFloat) {
        self.stackView.alpha = alpha
    }
}
