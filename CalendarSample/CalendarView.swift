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
    
    var cellHeight: CGFloat = 0.0
    var disposeBag: DisposeBag = DisposeBag()
    var isGestureDown: Bool = false
    
    var monthContainerCell: CalendarMonthContainerCell?
    var weekContainerCell: CalendarWeekContainerCell?
    var date: Date = Date()
    var isOnlyWeek: Bool = false
    
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
        
//        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MonthCell")
        self.collectionView.registerNib(type: CalendarMonthContainerCell.self)
        self.collectionView.registerNib(type: CalendarEventCell.self)
        self.collectionView.register(UINib(nibName: "\(CalendarHeaderReusableView.self)", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(CalendarHeaderReusableView.self)")
        
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
               isOnlyWeek: Bool,
               width: CGFloat = UIScreen.main.bounds.width,
               cellHeight: CGFloat = 60.0,
               callbackSelect: ((Date?) -> Void)?) {
        self.callbackSelect = callbackSelect
        self.cellHeight = cellHeight
        self.isOnlyWeek = isOnlyWeek
        self.date = selectDate ?? Date()
        
        if isOnlyWeek {
            //TODO: 주 달력 전용처리 필요
        } else {
            self.calendarCellHeight = CGFloat(Calendar.current.getMonthOfWeekCount(date: self.date)) * self.cellHeight //+ Common.TOP_HEIGHT

            if self.weekContainerCell == nil {
                self.weekContainerCell = Bundle.main.loadNibNamed("\(CalendarWeekContainerCell.self)", owner: self)?.first as? CalendarWeekContainerCell
            }
        }
    }
    
    func moveScroll(scrollView: UIScrollView, isFinish: Bool) {
        if let cell = self.monthContainerCell, let weekCell = self.weekContainerCell {
            
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
                    weekCell.isHidden = false
                    cell.changeWeekView(cell: weekCell)
                }

                if self.subviews.count > 1, offset.y < max {
                    //week -> month 스트롤 시작
                    cell.reloadCurrent(cell: weekCell)
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
                    self.addSubview(weekCell)
                    var frame = weekCell.frame
                    frame.origin.y = Common.TOP_HEIGHT
                    frame.origin.x = 0.0
                    weekCell.frame = frame
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
            if self.monthContainerCell == nil {
                self.monthContainerCell = collectionView.dequeueReusableCell(type: CalendarMonthContainerCell.self, indexPath: indexPath)
                self.monthContainerCell?.setup(delegate: self, cellHeight: self.cellHeight)
            }
            
            return self.monthContainerCell!
            
        } else {
            let cell = collectionView.dequeueReusableCell(type: CalendarEventCell.self, indexPath: indexPath)
            cell.setup(row: indexPath.row)
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(CalendarHeaderReusableView.self)", for: indexPath) as? CalendarHeaderReusableView
            header?.setup(date: self.selectedDate(), callbackMove: { [weak self] isNext in
                if self?.scope() == .week {
                    let index = isNext ? 2 : 0
                    self?.weekContainerCell?.scrollToIndex(index: index, isAnimation: true)
                } else {
                    self?.monthContainerCell?.moveAction(isNext: isNext)
                }
            })
            
            return header ?? UICollectionReusableView()
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: 90.0)
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
        if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? CalendarHeaderReusableView {
            header.update(date: date)
        }
    }
    
    func selectDate(date: Date) {
        self.date = date
        self.callbackSelect?(date)
        //TODO: 이벤트목록
    }
    
    func selectedDate() -> Date {
        return self.date
    }
    
    func scope() -> CalendarScope {
        let currentHeight = self.monthContainerCell?.currentCollectionViewHeight()
        let monthHeight = self.monthContainerCell?.getModeHeight(scope: .month)
        let weekHeight = self.monthContainerCell?.getModeHeight(scope: .week)
        
        switch currentHeight {
        case monthHeight :
            return .month
        case weekHeight :
            return .week
        default:
            return .changing
        }
    }
}
