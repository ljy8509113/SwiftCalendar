//
//  CalendarView.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/15.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import RxGesture

class CalendarView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayEvent: [String] = []
    var calendarCellHeight: CGFloat = 0.0
    
    var callbackSelect: ((Date?) -> Void)?
    var scope: CalendarScope = .month
    
    var cellHeight: CGFloat = 0.0
    var disposeBag: DisposeBag = DisposeBag()
    var isGestureDown: Bool = false
    
    var monthContainerCell: CalendarMonthContainerCell?
    var weekContainerCell: CalendarWeekContainerCell?
    var date: Date = Date()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        if self.subviews.count == 0, let view = Bundle.main.loadNibNamed("\(CalendarView.self)", owner: self)?.first as? UIView {
            self.addSubview(view)
            view.frame = self.bounds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for i in 0...10 {
            self.arrayEvent.append("\(i)")
        }
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MonthCell")
        self.collectionView.registerNib(type: CalendarEventCell.self)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 10.0
        flow.minimumInteritemSpacing = 0.0
        flow.scrollDirection = .vertical
        flow.sectionHeadersPinToVisibleBounds = true
        
        //        let flow = CalendarCollectionViewFlowLayout(stickyIndexPath: self.stickyIndexPath)
        self.collectionView.collectionViewLayout = flow
        
        self.collectionView.rx.panGesture().bind(with: self, onNext: { [weak self] obj, gesture in
            self?.isGestureDown = gesture.velocity(in: self).y > 0.0
            //            print(" :: \(self?.isGestureDown)")
        }).disposed(by: self.disposeBag)
    }
    
    func setup(selectDate: Date?,
               scope: CalendarScope = .month,
               width: CGFloat = UIScreen.main.bounds.width,
               cellHeight: CGFloat = 60.0,
               callbackSelect: ((Date?) -> Void)?) {
        self.callbackSelect = callbackSelect
        self.scope = scope
        self.cellHeight = cellHeight
        //        self.selectDate = date
        
        self.date = selectDate ?? Date()
        
        self.calendarCellHeight = CGFloat(Calendar.current.getMonthOfWeekCount(date: self.date)) * self.cellHeight + Common.TOP_HEIGHT
        
        if self.monthContainerCell == nil {
            self.monthContainerCell = Bundle.main.loadNibNamed("\(CalendarMonthContainerCell.self)", owner: self)?.first as? CalendarMonthContainerCell
        }
        
        if self.weekContainerCell == nil {
            self.weekContainerCell = Bundle.main.loadNibNamed("\(CalendarWeekContainerCell.self)", owner: self)?.first as? CalendarWeekContainerCell
        }
    }
    
    func moveScroll(scrollView: UIScrollView, isFinish: Bool) {
        if let cell = self.monthContainerCell {
            
            let offset = scrollView.contentOffset
            let monthHeight = cell.monthCollectionViewHeight(index: 1)
            let max = monthHeight - self.cellHeight
            let current = cell.currentCollectionViewHeight()
//            print("y: \(offset.y) :: \(max) current : \(current) :: \(monthHeight)")
            if offset.y <= max || (current != monthHeight && current != self.cellHeight) {
                if offset.y <= 0.0, current == monthHeight {
                    return
                }
                
                if offset.y > 0.0, current == monthHeight {
                    //month -> week 스크롤 시작
                    if let weekCell = self.weekContainerCell {
                        weekCell.isHidden = false
                        cell.changeWeekView(cell: weekCell)
                    }
                }
                
                if self.subviews.count > 1, offset.y < max {
                    //week -> month 스트롤 시작
                    var frame = cell.frame
                    frame.origin.y = 0.0
                    cell.frame = frame
                    self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.contentView.addSubview(cell)
                    if let weekCell = self.weekContainerCell {
                        cell.reloadCurrent(cell: weekCell)
                    }
                }
                
                let height = monthHeight - offset.y
                var moveY = offset.y
                
                if height < self.cellHeight {
                    moveY = monthHeight - self.cellHeight
                } else if height > monthHeight {
                    moveY = 0.0
                }
                
                cell.moveScroll(pointY: moveY, isFinish: isFinish)
            }
            
            if isFinish {
                //유저가 스크롤에서 손을 때거나 Decelerating 되었을때
                if offset.y > 0, offset.y <= max {
                    let monthHeight = cell.monthCollectionViewHeight(index: 1)
                    let weekHeight = cell.cellHeight
                    if self.isGestureDown == true {
                        if current < monthHeight {
                            let y = 0.0
                            self.collectionView.isUserInteractionEnabled = false
                            self.collectionView.setContentOffset(CGPoint(x: 0.0, y: y), animated: true)
                            print("111 - isUserInteractionEnabled false")
                        }
                    } else {
                        if current > self.cellHeight {
                            let y = monthHeight - weekHeight
                            self.collectionView.isUserInteractionEnabled = false
                            self.collectionView.setContentOffset(CGPoint(x: 0.0, y: y), animated: true)
                            print("222 - isUserInteractionEnabled false")
                        }
                    }
                }
            }
            
            if offset.y >= max {
                if self.subviews.count == 1 {
                    //week
                    self.addSubview(cell)
                    var frame = cell.frame
                    frame.origin.y = -(cell.getModeHeight(scope: .month) - cell.getModeHeight(scope: .week))
//                    frame.origin.y = -(Common.TOP_HEIGHT + self.cellHeight)
                    frame.origin.x = 0.0
                    cell.frame = frame
                    self.collectionView.isUserInteractionEnabled = true
                    print("333 - isUserInteractionEnabled true")
                }
            } else {
                if offset.y <= 0.0, !isFinish, self.weekContainerCell?.isHidden == false {
                    self.weekContainerCell?.isHidden = true
                    cell.collectionView.reloadData()
                    self.collectionView.isUserInteractionEnabled = true
                    print("444 - isUserInteractionEnabled true")
                }
            }
        }
    }
    
    func monthOfRowCount (date: Date) -> Int {
        let start = Calendar.current.startDayOfWeek(date: date)
        let end = Calendar.current.endDate(date: date) ?? 0
        let monthEnd = end + start
        var rows = monthEnd / 7
        if monthEnd % 7 > 0 {
            rows += 1
        }
        return rows
    }
}

extension CalendarView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll :: \(scrollView.contentOffset)")
        moveScroll(scrollView: scrollView, isFinish: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("vc scrollViewDidEndDecelerating :")
        moveScroll(scrollView: scrollView, isFinish: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging  :: \(decelerate)")
        if !decelerate {
            moveScroll(scrollView: scrollView, isFinish: true)
        }
    }
}

extension CalendarView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.arrayEvent.count == 0 ? 1 : self.arrayEvent.count
        return count // + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
//            let cell = collectionView.dequeueReusableCell(type: CalendarMonthContainerCell.self, indexPath: indexPath)
//            cell.setup(scope: self.scope, delegate: self, cellHeight: self.cellHeight)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath)

            if cell.contentView.subviews.count == 0, let calendar = self.monthContainerCell {
                cell.contentView.addSubview(calendar)
                var frame = cell.frame
                frame.origin.y = 0.0
                frame.size.height = calendar.maxHeight(cellHeight: self.cellHeight)
                calendar.frame = frame
                calendar.setup(scope: self.scope,  delegate: self, cellHeight: self.cellHeight)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(type: CalendarEventCell.self, indexPath: indexPath)
            cell.setup(row: indexPath.row)
            return cell
        }
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        if indexPath.row == 0 {
//            print("viewcontroller : h : \(self.calendarCellHeight) :: ")
            return CGSize(width: width, height: self.calendarCellHeight)
        } else {
            return CGSize(width: width, height: 100)
        }
    }
}

extension CalendarView: CalendarDelegate {
    func changeHeight(height: CGFloat) {
        if self.calendarCellHeight != height {
            print("changeHeight: current: \(self.calendarCellHeight) :: chage: \(height)")
            if self.collectionView.contentOffset.y > 0.0 {
                let gab = height - self.calendarCellHeight
                self.monthContainerCell?.constraintTop.constant += gab
            }
            self.calendarCellHeight = height
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func changeWeek(date: Date) {
    }
    
    func selectDate(date: Date) {
        self.date = date
        self.callbackSelect?(date)
        //TODO: 이벤트목록
    }
    
    func selectedDate() -> Date {
        return self.date
    }
}
