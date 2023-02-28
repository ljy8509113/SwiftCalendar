//
//  CalendarMonthContainerCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/22.
//

import UIKit
import RxCocoa
import RxSwift

class CalendarMonthContainerCell: UICollectionViewCell {
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var labelMonth: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintCollectionHeight: NSLayoutConstraint!
    
    var scope: CalendarScope = .month
    
    var arrayMonth: [CalendarMonthObject] = []
    var cellHeight: CGFloat = Common.CELL_HEIGHT
    
    var isInit: Bool = true
    var formatter = DateFormatter()
    var calendar = Calendar.current
    
    var delegate: CalendarDelegate?
    
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
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerNib(type: CalendarMonthCell.self)
        self.collectionView.isPagingEnabled = true
        //        self.collectionView.tag = 1
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumLineSpacing = 0.0
        flow.minimumInteritemSpacing = 0.0
        //        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.collectionView.collectionViewLayout = flow
        
    }
    
    func setup(scope: CalendarScope = .month,
               delegate: CalendarDelegate,
               width: CGFloat = UIScreen.main.bounds.width,
               cellHeight: CGFloat) {
        self.scope = scope
        self.cellHeight = cellHeight
        self.delegate = delegate
        
        setArray(date: selectedDate())
        
        self.constraintCollectionHeight.constant = self.cellHeight * 6.0
    }
    
    func setArray(date: Date){
        self.arrayMonth.removeAll()
        
        guard let previous = getMonthDate(date: date, addValue: -1), let next = getMonthDate(date: date, addValue: 1) else {
            return
        }
        
        print("array month pre: \(previous) date : \(date) next: \(next)")
        
        let previousMonth = CalendarMonthObject(date: previous)
        let currentMonth = CalendarMonthObject(date: date)
        let nextMonth = CalendarMonthObject(date: next)
        
        self.arrayMonth.append(contentsOf: [previousMonth, currentMonth, nextMonth])
    }
    
    func scrollToIndex(index: Int, isAnimation: Bool = false) {
        let width = collectionView.frame.size.width
        var x = width
        
        if index == 0 {
            x = 0.0
        } else if index == 2 {
            x = collectionView.contentSize.width - width
        }
        self.collectionView.setContentOffset(CGPoint(x: x, y: 0.0), animated: isAnimation)
        self.labelMonth.text = formatter.string(from: selectedDate())
        
    }
    
    func scrollToCenter(scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        if x <= 0.0 {
            setPreviousMonth()
        } else if x > scrollView.frame.size.width {
            setNextMonth()
        }
        self.collectionView.reloadData()
        scrollToIndex(index: 1)
        
        let height = monthCollectionViewHeight(index: 1)
        changeHeight(height: height)
        
        self.collectionView.performBatchUpdates({ [weak self] in
            guard let strongSelf = self else {
                return
            }
            let select = strongSelf.arrayMonth[1].date
            if let date = getFirstDayOfMonth(date: select) {
                strongSelf.selectDate(date: date)
                strongSelf.setSelectDay(date: date)
            }
        })
    }
    
    func setPreviousMonth() {
        setArray(date: self.arrayMonth[0].date)
    }
    
    func setNextMonth()  {
        setArray(date: self.arrayMonth[2].date)
    }
    
    func getMonthDate(date: Date, addValue: Int) -> Date? {
        return self.calendar.date(byAdding: DateComponents(month: addValue), to: date)
    }
    
    func getFirstDayOfMonth(date: Date) -> Date? {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return calendar.date(from: DateComponents(year: year, month: month, day: 1))
    }
    
    
    func getWeekDate(date: Date, addValue: Int) -> Date? {
        return self.calendar.date(byAdding: DateComponents(weekOfMonth: addValue), to: date)
    }
    
    func getCenterCell() -> CalendarMonthCell? {
        if let cell = currentCell() {
            return cell
        }
        return nil
    }
    
    func topSize() -> CGFloat {
        return self.viewTop.frame.size.height + self.stackView.frame.size.height
    }
    
    func moveScroll(pointY: CGFloat, isFinish: Bool) {
        guard let cell = currentCell() else {
            return
        }
        
        cell.moveScroll(pointY: pointY, isFinish: isFinish)
        self.constraintTop.constant = pointY
//        self.layoutIfNeeded()
        
        let monthHeight = monthCollectionViewHeight(index: 1)
        if pointY == monthHeight - self.cellHeight {
            self.collectionView.isScrollEnabled = false
            self.scope = .week
            
        } else if pointY == 0.0 {
            self.collectionView.isScrollEnabled = true
            self.scope = .month
            self.collectionView.reloadData()
        } else {
            self.collectionView.isScrollEnabled = false
            self.scope = .changing
        }
        cell.scope = self.scope
    }

    func getModeHeight(scope: CalendarScope) -> CGFloat {
        if scope == .month {
            return monthCollectionViewHeight(index: 1) + topSize()
        } else {
            return self.cellHeight + topSize()
        }
    }
    
    func monthCollectionViewHeight(index: Int) -> CGFloat {
        let count = self.arrayMonth[index].arrayWeek.count
        let height = self.cellHeight * CGFloat(count)
        return height
    }
    
    func maxHeight(cellHeight: CGFloat) -> CGFloat {
        return cellHeight * 6.0 + topSize()
    }
    
    func currentCollectionViewHeight() -> CGFloat {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: 1, section: 0)) as? CalendarMonthCell {
            return cell.visibleCellsHeight()
        }
        return .zero
    }
    
    func setSelectDay(date: Date) {
        if let cell = currentCell() {
            cell.setSelectDay(date: date)
        }
    }
    
    func changeWeekView(cell: CalendarWeekContainerCell) {
        if let month = currentCell() {
            month.changeWeekView(cell: cell)
        }
    }
    
    func currentCell() -> CalendarMonthCell? {
        return self.collectionView.visibleCells.first(where: { $0.tag == 1}) as? CalendarMonthCell
    }
    
    func reloadCurrent(cell: CalendarWeekContainerCell) {
        setArray(date: self.selectedDate())
        let data = self.arrayMonth[1]
        currentCell()?.updateDate(data: data, cell: cell)
    }
    
    @IBAction func onNext(_ sender: Any) {
        if self.scope == .month {
            scrollToIndex(index: 2, isAnimation: true)
        } else if self.scope == .week {
            if let cell = currentCell() {
                cell.moveWeekIndex(index: 2)
            }
        }
    }
    
    @IBAction func onPrevioues(_ sender: Any) {
        if self.scope == .month {
            scrollToIndex(index: 0, isAnimation: true)
        } else if self.scope == .week {
            if let cell = currentCell() {
                cell.moveWeekIndex(index: 0)
            }
        }
    }
}

extension CalendarMonthContainerCell: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating :: \(scrollView.contentOffset.x)")
        if scrollView.contentOffset.x != scrollView.frame.size.width {
            scrollToCenter(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation :: \(scrollView.contentOffset.x)")
        if scrollView.contentOffset.x != scrollView.frame.size.width {
            scrollToCenter(scrollView: scrollView)
        }
    }
}

extension CalendarMonthContainerCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(type: CalendarMonthCell.self, indexPath: indexPath)
        let data = self.arrayMonth[indexPath.row]
        cell.tag = indexPath.row
//        cell.setup(scope: self.scope, data: data, selectDate: self.selectDate, cellHeight: self.cellHeight, delegate: self)
        cell.setup(scope: self.scope, data: data, cellHeight: self.cellHeight, delegate: self)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.isInit {
            self.isInit = false
            scrollToIndex(index: 1)
        }
    }
    
}

extension CalendarMonthContainerCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
//        return CGSize(width: width, height: self.constraintCollectionHeight.constant)
        return CGSize(width: width, height: self.cellHeight * 6.0)
    }
}

extension CalendarMonthContainerCell : CalendarDelegate {
    func changeHeight(height: CGFloat) {
        print("changeHeight: \(height)")
        let cellHeight = height + topSize()
        self.delegate?.changeHeight(height: cellHeight)
    }
    
    func changeWeek(date: Date) {
    }
    
    func selectDate(date: Date) {
        self.delegate?.selectDate(date: date)
        self.labelMonth.text = self.formatter.string(from: date)
    }
    
    func selectedDate() -> Date {
        return self.delegate?.selectedDate() ?? Date()
    }
    
}
