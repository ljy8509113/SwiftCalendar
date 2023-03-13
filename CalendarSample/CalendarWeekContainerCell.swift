//
//  CalendarWeekContainerCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import UIKit
import Cartography

class CalendarWeekContainerCell: UICollectionViewCell {
    var collectionView: UICollectionView?
    var constraintHeight: NSLayoutConstraint?
    
    var calendar = Calendar.current
    var cellHeight: CGFloat = 0.0
    
    var arrayWeek: [CalendarWeekObject] = []
    var data: CalendarWeekObject?
    
    var delegate: CalendarProtocol?
    var isInit: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        if self.collectionView == nil {
            self.backgroundColor = .clear
            let flow = UICollectionViewFlowLayout()
            flow.scrollDirection = .horizontal
            flow.minimumLineSpacing = 0.0
            flow.minimumInteritemSpacing = 0.0
            flow.sectionInset = .zero
            
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
            self.contentView.addSubview(self.collectionView!)
            self.collectionView?.backgroundColor = .clear
            Cartography.constrain(self.collectionView!) { [weak self] (v) in
                self?.constraintHeight = v.height == 60.0
                v.top == v.superview!.top
                v.leading == v.superview!.leading
                v.trailing == v.superview!.trailing
            }
            
//            self.collectionView?.registerNib(type: CalendarWeekCell.self)
            self.collectionView?.register(CalendarWeekCell.self, forCellWithReuseIdentifier: "\(CalendarWeekCell.self)")
            self.collectionView?.delegate = self
            self.collectionView?.dataSource = self
            self.collectionView?.isPagingEnabled = true
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(data: CalendarWeekObject?,
               cellHeight: CGFloat,
               delegate: CalendarProtocol?) {
        
        self.delegate = delegate
        self.data = data
        self.cellHeight = cellHeight
        self.constraintHeight?.constant = ceil(cellHeight)
        
        if let date = data?.date {
            setArray(date: date)
            self.collectionView?.reloadData()
            self.collectionView?.performBatchUpdates({}, completion: { [weak self] _ in
                if self?.isInit == false {
                    self?.scrollToIndex(index: 1)
                }
            })
        }
    }
    
    func setArray(date: Date) {
        self.arrayWeek.removeAll()
        self.data?.date = date
        
        let previous = getWeekDate(date: date, addValue: -1)
        let next = getWeekDate(date: date, addValue: 1)
        //        print("array week pre: \(previous) date : \(date) next: \(next)")
        
        let previousWeek = CalendarWeekObject(date: previous, array: nil)
        let currentWeek = CalendarWeekObject(date: date, array: nil)
        let nextWeek = CalendarWeekObject(date: next, array: nil)
        
        self.arrayWeek.append(contentsOf: [previousWeek, currentWeek, nextWeek])
    }
    
    func getWeekDate(date: Date, addValue: Int) -> Date? {
        return self.calendar.date(byAdding: DateComponents(weekOfMonth: addValue), to: date)
    }
    
    func setPreviousWeek() {
        if let previous = self.arrayWeek[0].date {
            setArray(date: previous)
        }
    }
    
    func setNextWeek() {
        if let next = self.arrayWeek[2].date {
            setArray(date: next)
        }
    }
    
    func scrollToIndex(index: Int, isAnimation: Bool = false) {
        let width = self.collectionView?.frame.size.width ?? 0.0
        var x = width
        
        if index == 0 {
            x = 0.0
        } else if index == 2 {
            x = (self.collectionView?.contentSize.width ?? 0.0) - width
        }
        self.collectionView?.setContentOffset(CGPoint(x: x, y: 0.0), animated: isAnimation)
    }
    
    func scrollToCenter(scrollView: UIScrollView, isNoti: Bool) {
        let x = scrollView.contentOffset.x
        if x <= 0.0 {
            setPreviousWeek()
        } else if x > scrollView.frame.size.width {
            setNextWeek()
        }
        
        self.collectionView?.reloadData()
        scrollToIndex(index: 1)
        
        self.collectionView?.performBatchUpdates({}, completion: { [weak self] _ in
            if isNoti {
                if let selectDate = self?.arrayWeek[1].date {
                    self?.delegate?.changeWeek(date: selectDate)
                    self?.setSelectDay(date: selectDate)
                }
            }
        })
    }
    
    func setSelectDay(date: Date?) {
        if let select = date {
            self.delegate?.selectDate(date: select)
            self.collectionView?.visibleCells.forEach({
                if let cell = $0 as? CalendarWeekCell {
                    cell.stackView?.subviews.forEach({
                        if let view = $0 as? CalendarDayView, let viewDate = view.data?.date {
                            view.setSelectDay(isSelect: self.delegate?.selectedDate().isSameDate(date: viewDate) == true)
                        }
                    })
                }
            })
        }
    }
    
    func moveDate(date: Date) {
        if let weekOfFirstDay = self.calendar.startDayOfWeek(date: date) {
            self.data?.update(date: weekOfFirstDay)
            setArray(date: weekOfFirstDay)
            self.collectionView?.reloadData()
            self.collectionView?.performBatchUpdates({}, completion: { [weak self] _ in
                self?.scrollToIndex(index: 1)
                self?.setSelectDay(date: date)
            })
        }
    }
    
    func changeHeight(height: CGFloat, alpha: CGFloat) {
        self.alpha = alpha
        self.cellHeight = height
        self.constraintHeight?.constant = ceil(height)
    }
}

extension CalendarWeekContainerCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayWeek.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CalendarWeekCell.self)", for: indexPath) as! CalendarWeekCell
        let data = self.arrayWeek[indexPath.row]
        cell.tag = indexPath.row
        cell.setup(delegate: self.delegate, array: data.arrayDays, cellHeight: self.cellHeight, callbackOnClick: { [weak self] date in
            if let date = date {
                self?.setSelectDay(date: date)
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isInit {
            isInit = false
            scrollToIndex(index: 1)
        }
    }
}

extension CalendarWeekContainerCell: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != scrollView.frame.size.width {
            scrollToCenter(scrollView: scrollView, isNoti: true)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != scrollView.frame.size.width {
            scrollToCenter(scrollView: scrollView, isNoti: true)
        }
    }
}

extension CalendarWeekContainerCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: self.cellHeight)
    }
}
