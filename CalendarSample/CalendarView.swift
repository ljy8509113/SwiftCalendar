//
//  CalendarView.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/15.
//

import UIKit
import Cartography

protocol CalendarProtocol {
    func changeHeight(height: CGFloat)
    func changeWeek(date: Date)
    func startedDate() -> Date?
    func selectDate(date: Date)
    func selectedDate() -> Date
    func status() -> CalendarStatus
    func type() -> CalendarType?
    func weekCellHeight() -> CGFloat
}

class CalendarView: UIView {
    var collectionView: UICollectionView?
    
    var arrayEvent: [ArtistNewsEventObject]?
    var calendarCellHeight: CGFloat = 0.0
    
    var callbackSelect: ((Date?) -> Void)?
    
    var cellHeight: CGFloat = 80.0
    var isGestureDown: Bool = false
    
    var monthContainerCell: CalendarMonthContainerCell?
    
    var date: Date = Date()
    var calendarType: CalendarType = .onlyMonth
    
    var weekData: CalendarWeekObject?
    
    let EVENT_HEIGHT = 100.0
    let HEADER_HEIGHT = 70.0
    
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
        let flow = UICollectionViewFlowLayout()
//        let flow = CalendarCollectionViewFlowLayout(stickyIndexPath: IndexPath(row: 0, section: 0))
//        let flow = CalendarCollectionViewFlowLayout(type: .onlyMonth)
        flow.minimumLineSpacing = 10.0
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
        
//        self.collectionView?.registerNib(type: CalendarWeekCell.self)
        self.collectionView?.register(CalendarWeekCell.self, forCellWithReuseIdentifier: "\(CalendarWeekCell.self)")
        self.collectionView?.registerNib(type: CalendarMonthContainerCell.self)
        self.collectionView?.registerNib(type: ANEventCell.self)
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = .clear
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setup(startDate: Date?,
               selectDate: Date?,
               type: CalendarType,
               events: [ArtistNewsEventObject]?,
               width: CGFloat = UIScreen.main.bounds.width,
               cellHeight: CGFloat = 80.0,
               callbackSelect: ((Date?) -> Void)?) {
        
        self.callbackSelect = callbackSelect
        self.cellHeight = cellHeight
        self.calendarType = type
        self.date = selectDate ?? Date()
        self.startDate = startDate
//        self.arrayEvent = events
        
        switch type {
        case .onlyWeek:
            self.calendarCellHeight = self.cellHeight + 30.0
            self.collectionView?.isScrollEnabled = false
            let startDate = Date().addingTimeInterval(-(24 * 60 * 60))
            self.weekData = CalendarWeekObject(date: startDate, array: nil)
            
            self.arrayEvent = []
            for i in 0...5 {
                let data = ArtistNewsEventObject()
                data.identifier = i
                self.arrayEvent!.append(data)
            }
        case .onlyMonth:
            self.calendarCellHeight = monthHeight(date: self.date)
            self.collectionView?.isScrollEnabled = false
        default:
            break
        }
    }
    
    func monthHeight(date: Date) -> CGFloat {
        if let cell = self.monthContainerCell {
            return cell.getModeHeight(status: .month)
        }
        return CGFloat(Calendar.current.getMonthOfWeekCount(date: date)) * self.cellHeight + HEADER_HEIGHT
    }
    
    func updateEvents(events: [ArtistNewsEventObject]?) {
        
    }
}



extension CalendarView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.calendarType == .onlyWeek {
            let count = self.arrayEvent?.count ?? 1
            return (count == 0 ? 1 : count) + 1
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            if self.calendarType == .onlyWeek {
                let cell = collectionView.dequeueReusableCell(type: CalendarWeekCell.self, indexPath: indexPath)
                if let array = self.weekData?.arrayDays {
                    cell.setup(delegate: self, array: array, cellHeight: self.cellHeight, callbackOnClick: { [weak self] date in
                        
                    })
                }
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
                            case .onlyMonth:
                                self?.monthContainerCell?.moveDate(date: date)
                            default:
                                break
                            }
                        case .previous, .next:
                            let index = move == .next ? 2 : 0
                            if self?.status() == .week {
                                switch self?.calendarType {
                                case .onlyMonth:
                                    self?.monthContainerCell?.scrollToIndex(index: index, isAnimation: true)
                                default:
                                    break
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
            let data = self.arrayEvent?[indexPath.row - 1]
            cell.setup(data: data)
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
            return CGSize(width: width, height: EVENT_HEIGHT)
        }
    }
}

extension CalendarView: CalendarProtocol {
    func changeHeight(height: CGFloat) {
        if self.calendarCellHeight != height {
//            print("changeHeight: current: \(self.calendarCellHeight) :: chage: \(height)")
            self.calendarCellHeight = height
            self.collectionView?.collectionViewLayout.invalidateLayout()
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
