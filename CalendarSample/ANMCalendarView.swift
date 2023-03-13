//
//  ANMainCalendarView.swift
//  CalendarSample
//
//  Created by Murf on 2023/03/07.
//

import UIKit
import Cartography

class ANMCalendarView: UIView {
    var collectionView: UICollectionView?
    
    var arrayEvent: [ArtistNewsEventObject]?
    var calendarCellHeight: CGFloat = 0.0
    
    var callbackSelect: ((Date?) -> Void)?
    
    var cellHeight: CGFloat = 0.0
    var isGestureDown: Bool = false
    
    var monthContainerCell: CalendarMonthContainerCell?
    var weekContainerCell: CalendarWeekContainerCell?
    var date: Date = Date()
    var calendarType: CalendarType = .monthAndWeek
    
    var weekData: CalendarWeekObject?
    
    let EVENT_HEIGHT = 80.0
    let CALENDAR_HEADER_HEIGHT = 90.0
    
    var startDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        self.arrayEvent = []
        for i in 0...1 {
            let data = ArtistNewsEventObject()
            data.identifier = i
            self.arrayEvent!.append(data)
        }

        let flow = CalendarCollectionViewFlowLayout(type: .monthAndWeek)
        flow.minimumLineSpacing = 0.0
        flow.minimumInteritemSpacing = 0.0
        flow.scrollDirection = .vertical
//        flow.sectionHeadersPinToVisibleBounds = true
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
        self.addSubview(self.collectionView!)
        
        Cartography.constrain(self.collectionView!) { v in
            v.leading == v.superview!.leading
            v.top == v.superview!.top
            v.trailing == v.superview!.trailing
            v.bottom == v.superview!.bottom
        }
        
        self.collectionView?.registerNib(type: CalendarWeekContainerCell.self)
        self.collectionView?.registerNib(type: CalendarMonthContainerCell.self)
        self.collectionView?.registerNib(type: ANEventCell.self)
        self.collectionView?.registerNib(type: ANMFilterTitleCell.self)
        self.collectionView?.registerNib(type: ANMFilterCell.self)
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = .clear
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(_ :)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkBottomMargin()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self.collectionView!)
        if abs(velocity.y) > abs(velocity.x) {
            self.isGestureDown = !(velocity.y < 0) // ? print("up") :  print("down")
        }
    }
    
    func setup(startDate: Date?,
               selectDate: Date?,
               events: [ArtistNewsEventObject]?,
               width: CGFloat = UIScreen.main.bounds.width,
               cellHeight: CGFloat = 80.0,
               callbackSelect: ((Date?) -> Void)?) {
        
        self.callbackSelect = callbackSelect
        self.cellHeight = cellHeight
        self.calendarType = .monthAndWeek
        self.date = selectDate ?? Date()
        self.startDate = startDate
//        self.arrayEvent = events
        
        switch self.calendarType {
        case .monthAndWeek:
            self.calendarCellHeight = monthHeight(date: self.date)
            
            if self.weekContainerCell == nil {
                self.weekContainerCell = CalendarWeekContainerCell(frame: CGRect(x: 0.0, y: 0.0, width: width, height: self.cellHeight))
//                self.weekContainerCell = CalendarWeekContainerCell(frame: CGRect(x: 0.0, y: 0.0, width: width, height: weekCellHeight()))
            }
        case .onlyWeek:
            self.calendarCellHeight = self.cellHeight
            self.collectionView?.isScrollEnabled = false
            self.weekData = CalendarWeekObject(date: self.date, array: nil)
        case .onlyMonth:
            self.calendarCellHeight = monthHeight(date: self.date)
            self.collectionView?.isScrollEnabled = false
        }
    }
    
    func moveScroll(scrollView: UIScrollView, isFinish: Bool) {
        if let cell = self.monthContainerCell, let weekCell = self.weekContainerCell {
            
            let offset = scrollView.contentOffset
            let monthHeight = cell.monthCollectionViewHeight(index: 1)
            let weekCellHeight = weekCellHeight()
            let max = monthHeight - weekCellHeight
            let current = cell.currentCollectionViewHeight()
            
//            print("y: \(offset.y) :: \(max) current : \(current) :: \(monthHeight)")
            if offset.y <= max || (current != monthHeight && current != weekCellHeight) {
                if offset.y <= 0.0, current == monthHeight {
                    return
                }

                if offset.y > 0.0, current == monthHeight {
                    // month -> week 스크롤 시작
                    weekCell.isHidden = false
                    cell.changeWeekView(cell: weekCell)
                }

                if self.subviews.count > 1, offset.y < max {
                    // week -> month 스트롤 시작
                    cell.reloadCurrent(cell: weekCell)
                }

                let height = monthHeight - offset.y
                var moveY = offset.y

                if height < weekCellHeight {
                    moveY = monthHeight - weekCellHeight
                } else if height > monthHeight {
                    moveY = 0.0
                }

                cell.moveScroll(pointY: moveY, isFinish: isFinish)
            }

            if isFinish {
                // 유저가 스크롤에서 손을 때거나 Decelerating 되었을때
                if offset.y > 0, offset.y <= max {
                    let monthHeight = cell.monthCollectionViewHeight(index: 1)
//                    let weekHeight = cell.cellHeight
                    if self.isGestureDown == true {
//                        if current < monthHeight {
                        if offset.y > 0.0 {
                            let y = 0.0
                            self.collectionView?.isUserInteractionEnabled = false
                            self.collectionView?.setContentOffset(CGPoint(x: 0.0, y: y), animated: true)
//                            print("111 - isUserInteractionEnabled false")
                        }
                    } else {
//                        if current > weekCellHeight {
                        let height = monthHeight - weekCellHeight
                        if offset.y < height {
//                            let y = monthHeight - weekCellHeight
                            self.collectionView?.isUserInteractionEnabled = false
                            self.collectionView?.setContentOffset(CGPoint(x: 0.0, y: height), animated: true)
//                            print("222 - isUserInteractionEnabled false")
                        }
                    }
                }
            }

            if offset.y >= max {
                if self.subviews.count == 1 {
                    // week
                    self.addSubview(weekCell)
                    var frame = weekCell.frame
                    frame.origin.y = self.calendarType.topArea(collectionView: self.collectionView!) + (self.monthContainerCell?.topSize() ?? 0.0)
                    frame.origin.x = 0.0
                    frame.size.height = weekCellHeight
                    weekCell.frame = frame
//                    weekCell.collectionView?.reloadData()
                    self.collectionView?.isUserInteractionEnabled = true
//                    print("333 - isUserInteractionEnabled true")
                }
            } else {
                if offset.y <= 0.0, !isFinish, self.weekContainerCell?.isHidden == false {
                    self.weekContainerCell?.isHidden = true
                    cell.collectionView?.reloadData()
                    self.collectionView?.isUserInteractionEnabled = true
//                    print("444 - isUserInteractionEnabled true")
                }
            }
            
        }
    }
    
    func monthHeight(date: Date) -> CGFloat {
        if let cell = self.monthContainerCell {
            return cell.getModeHeight(status: .month)
        }
        return CGFloat(Calendar.current.getMonthOfWeekCount(date: date)) * self.cellHeight + CALENDAR_HEADER_HEIGHT
    }
    
    func checkBottomMargin() {
        if self.calendarType == .monthAndWeek {
            // week 모드 height
            let eventCount = CGFloat(self.arrayEvent?.count ?? 1)
            let eventHeight = eventCount == 0 ? 1 * EVENT_HEIGHT : eventCount * EVENT_HEIGHT
            let monthCellHeight = monthHeight(date: self.date)
            let otherHeight = eventHeight + self.calendarType.topArea(collectionView: self.collectionView!)
            let weekHeight = otherHeight + weekCellHeight()
            let monthHeight = otherHeight + monthCellHeight
            let height = self.collectionView?.frame.size.height ?? 0.0

//            print("checkBottomMargin :: \(weekHeight) :: \(height)")

            var bottom: CGFloat = .zero
            if monthHeight > height && weekHeight < height {
                bottom = height - weekHeight
            }
            self.collectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottom, right: 0.0)
        }
    }
    
    func updateEvents(events: [ArtistNewsEventObject]?) {
        
    }
}

extension ANMCalendarView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ANMCalendarView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll :: \(scrollView.contentOffset)")
        moveScroll(scrollView: scrollView, isFinish: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("vc scrollViewDidEndDecelerating :")
        moveScroll(scrollView: scrollView, isFinish: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("scrollViewDidEndDragging  :: \(decelerate)")
        if !decelerate {
            moveScroll(scrollView: scrollView, isFinish: true)
        }
    }
}

extension ANMCalendarView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.calendarType == .monthAndWeek {
            let count = self.arrayEvent?.count ?? 1
            return (count == 0 ? 1 : count) + 3
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.calendarType.filterHeaderIndex()?.row {
            let cell = collectionView.dequeueReusableCell(type: ANMFilterTitleCell.self, indexPath: indexPath)
            return cell
        } else if indexPath.row == self.calendarType.filterIndex()?.row {
            let cell = collectionView.dequeueReusableCell(type: ANMFilterCell.self, indexPath: indexPath)
            return cell
        } else if indexPath.row == self.calendarType.calendarIndex().row {
            if self.calendarType == .onlyWeek {
                let cell = collectionView.dequeueReusableCell(type: CalendarWeekContainerCell.self, indexPath: indexPath)
                cell.setup(data: self.weekData, cellHeight: self.cellHeight, delegate: self)
                return cell
            } else {
                if self.monthContainerCell == nil {
//                    self.monthContainerCell = collectionView.dequeueReusableCell(type: CalendarMonthContainerCell.self, indexPath: indexPath)
                    self.monthContainerCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "\(CalendarMonthContainerCell.self)", for: indexPath) as! CalendarMonthContainerCell)
                    self.monthContainerCell?.setup(delegate: self, cellHeight: self.cellHeight, callbackMove: { [weak self] move in
                        
                        switch move {
                        case .today:
                            self?.selectDate(date: Date())
                            let date = self?.selectedDate() ?? Date()
                            self?.changeWeek(date: date)
                            switch self?.calendarType {
                            case .onlyWeek:
                                if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CalendarWeekContainerCell {
                                    cell.setArray(date: date)
                                    cell.collectionView?.reloadData()
                                }
                            case .onlyMonth:
                                self?.monthContainerCell?.moveDate(date: date)
                            case .monthAndWeek:
                                if self?.status() == .week {
                                    self?.weekContainerCell?.moveDate(date: date)
                                } else {
                                    self?.monthContainerCell?.moveDate(date: date)
                                }
                            default:
                                break
                            }
                        case .previous, .next:
                            let index = move == .next ? 2 : 0
                            if self?.status() == .week {
                                switch self?.calendarType {
                                case .onlyWeek:
                                    if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CalendarWeekContainerCell {
                                        cell.scrollToIndex(index: index, isAnimation: true)
                                    }
                                case .monthAndWeek:
                                    self?.weekContainerCell?.scrollToIndex(index: index, isAnimation: true)
                                default:
                                    self?.monthContainerCell?.scrollToIndex(index: index, isAnimation: true)
                                }
                            } else {
                                self?.monthContainerCell?.scrollToIndex(index: index, isAnimation: true)
                            }
                        }
                        
                    })
                }

                return self.monthContainerCell!
            }
        } else {
            let cell = collectionView.dequeueReusableCell(type: ANEventCell.self, indexPath: indexPath)
//            cell.setup(row: indexPath.row)
            let data = self.arrayEvent?[indexPath.row - 3]
            cell.setup(data: data)
            return cell
        }
    }
}

extension ANMCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        
        if indexPath.row == self.calendarType.filterHeaderIndex()?.row {
            return CGSize(width: width, height: 40.0)
        } else if indexPath.row == self.calendarType.filterIndex()?.row {
            return CGSize(width: width, height: 100.0)
        } else if indexPath.row == self.calendarType.calendarIndex().row {
            return CGSize(width: width, height: self.calendarCellHeight)
        } else {
            return CGSize(width: width, height: EVENT_HEIGHT)
        }
    }
}

extension ANMCalendarView: CalendarProtocol {
    func changeHeight(height: CGFloat) {
        if self.calendarCellHeight != height {
//            print("changeHeight: current: \(self.calendarCellHeight) :: chage: \(height)")
            self.calendarCellHeight = height
            self.collectionView?.collectionViewLayout.invalidateLayout()
            
            checkBottomMargin()
        }
    }
    
    func changeWeek(date: Date) {
    }
    
    func startedDate() -> Date? {
        return self.startDate
    }
    
    func selectDate(date: Date) {
        self.date = date
        self.callbackSelect?(date)
        // TODO: 이벤트목록
    }
    
    func selectedDate() -> Date {
        return self.date
    }
    
    func status() -> CalendarStatus {
        switch self.calendarType {
        case .onlyWeek:
            return .week
        case .onlyMonth:
            return .month
        default:
            let currentHeight = (self.monthContainerCell?.currentCollectionViewHeight() ?? 0.0) + (self.monthContainerCell?.topSize() ?? 0.0)
            let monthHeight = self.monthContainerCell?.getModeHeight(status: .month)
            let weekHeight = self.monthContainerCell?.getModeHeight(status: .week)
            
            switch currentHeight {
            case monthHeight:
                return .month
            case weekHeight:
                return .week
            default:
                return .changing
            }
        }
    }
    
    func type() -> CalendarType? {
        return self.calendarType
    }
    
    func weekCellHeight() -> CGFloat {
        return self.collectionView!.frame.size.width / 7.0
    }
}
