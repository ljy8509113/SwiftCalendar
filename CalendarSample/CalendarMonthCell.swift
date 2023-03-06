//
//  CalendarMonthCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/16.
//

import UIKit
import Cartography

class CalendarMonthCell: UICollectionViewCell {
    var collectionView: UICollectionView?
    
    var data: CalendarMonthObject?
    var cellHeight: CGFloat = 60.0
    
    var selectedRow: Int?
    var movePoint: CGFloat = 0.0
    
    var delegate: CalendarProtocol?
    
    var weekContainerCell: CalendarWeekContainerCell?
    var cellAlpha: CGFloat = 1.0
    
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
            flow.minimumInteritemSpacing = 0.0
            flow.minimumLineSpacing = 0.0
            flow.scrollDirection = .vertical
            flow.sectionInset = .zero
            
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
            self.collectionView?.backgroundColor = .clear
            self.contentView.addSubview(self.collectionView!)

            Cartography.constrain(self.collectionView!) { (v) in
                v.trailing == v.superview!.trailing
                v.top == v.superview!.top
                v.leading == v.superview!.leading
                v.bottom == v.superview!.bottom
            }
            
            self.collectionView?.register(CalendarWeekCell.self, forCellWithReuseIdentifier: "\(CalendarWeekCell.self)")
            self.collectionView?.delegate = self
            self.collectionView?.dataSource = self
            //        self.collectionView.backgroundColor = .white
            self.collectionView?.isScrollEnabled = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(data: CalendarMonthObject,
               cellHeight: CGFloat,
               delegate: CalendarProtocol) {
        
        self.data = data
        self.cellHeight = cellHeight
        self.delegate = delegate
        
        if self.delegate?.status() == .month {
            self.selectedRow = nil
        } else {
            self.selectedRow = existSelectedRow()
        }
        
        self.collectionView?.reloadData()
    }

    func moveScroll(pointY: Double, isFinish: Bool) {
        if self.selectedRow == nil {
            self.selectedRow = existSelectedRow()
        }
        
        let count = self.collectionView?.visibleCells.count ?? 0
        
        self.movePoint = pointY / CGFloat(count - 1)
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func existSelectedRow() -> Int? {
        if let data = self.data {
            return data.arrayWeek.firstIndex(where: {
                $0.arrayDays.first(where: {
                    $0.date?.isSameDate(date: selectedDate()) == true
                }) != nil
            })
        }
        return nil
    }
    
    func existSelectedCell() -> CalendarWeekCell? {
        return self.collectionView?.visibleCells.first(where: { ($0 as? CalendarWeekCell)?.exitsDate(date: self.selectedDate()) == true }) as? CalendarWeekCell
    }
    
    func visibleCellsHeight() -> CGFloat {
        var totalHeight: CGFloat = 0.0
        self.collectionView?.visibleCells.forEach({
            totalHeight += $0.frame.size.height
        })
        return totalHeight
    }
    
    func changeWeekView(cell: CalendarWeekContainerCell) {
        if let selectCell = existSelectedCell(), let row = existSelectedRow(), let weekData = self.data?.arrayWeek[row] {
            self.weekContainerCell = cell
            self.selectedRow = row
            if selectCell.contentView.subviews.first(where: { $0 is CalendarWeekContainerCell }) == nil {
                selectCell.contentView.addSubview(cell)
                cell.frame = selectCell.bounds
            }
            cell.setup(data: weekData, cellHeight: self.cellHeight, delegate: self)
        }
    }
    
    func setSelectDay(date: Date?) {
        if let date = date {
            self.delegate?.selectDate(date: date)
            self.collectionView?.visibleCells.forEach({
    //            if let cell = $0 as? CalendarWeekContainerCell {
                if let cell = $0 as? CalendarWeekCell {
                    cell.setSelectDay(date: date)
                }
            })
        }
    }
    
    func updateDate(data: CalendarMonthObject?, cell: CalendarWeekContainerCell) {
        self.data = data
        self.selectedRow = existSelectedRow()
        self.collectionView?.reloadData()
        self.collectionView?.performBatchUpdates({}, completion: { [weak self] _ in
            if let count = data?.arrayWeek.count, let cellHeight = self?.cellHeight {
                self?.changeHeight(height: CGFloat(count) * cellHeight)
            }
            self?.changeWeekView(cell: cell)
        })
    }
}

extension CalendarMonthCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.arrayWeek.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CalendarWeekCell.self)", for: indexPath) as! CalendarWeekCell
        cell.tag = indexPath.row
        if let weekData = self.data?.arrayWeek[indexPath.row] {
            cell.setup(delegate: self.delegate, array: weekData.arrayDays, cellHeight: self.cellHeight, callbackOnClick: { [weak self] date in
                self?.setSelectDay(date: date)
            })
            
            if self.delegate?.status() == .month {
                self.cellAlpha = 0.0
                cell.changeAlpha(alpha: 1.0)
            }
        }
        return cell
    }
}

extension CalendarMonthCell: UICollectionViewDelegate {
    
}

extension CalendarMonthCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.cellForItem(at: indexPath) as? CalendarWeekCell
        if let row = self.selectedRow, indexPath.row != row {
            
            var height = self.cellHeight - self.movePoint
            
            if height < 0.0 {
                height = 0.0
            } else if height > self.cellHeight {
                height = self.cellHeight
            }
            
            self.cellAlpha = height / self.cellHeight
            cell?.changeAlpha(alpha: self.cellAlpha)
//                print("1. cell index : \(indexPath.row) :: \(height)")
            return CGSize(width: collectionView.frame.size.width, height: height)
        } else {
            //            print("index: \(indexPath.row)")
            cell?.changeAlpha(alpha: self.cellAlpha)
            self.weekContainerCell?.alpha = 1.0 - self.cellAlpha
            
//            print("3. cell index : \(indexPath.row) :: \(self.cellHeight) :: \(self.cellAlpha)")
            return CGSize(width: collectionView.frame.size.width, height: self.cellHeight)
        }
    }
}

extension CalendarMonthCell: CalendarProtocol {
    func selectDate(date: Date) {
        self.setSelectDay(date: date)
    }
    
    func selectedDate() -> Date {
        return self.delegate?.selectedDate() ?? Date()
    }
    
    func startedDate() -> Date? {
        return self.delegate?.startedDate()
    }
    
    func changeHeight(height: CGFloat) {
        self.delegate?.changeHeight(height: height)
    }
    
    func changeWeek(date: Date) {
        selectDate(date: date)
        self.delegate?.changeWeek(date: date)
    }
    
    func status() -> CalendarStatus {
        return self.delegate?.status() ?? .month
    }
    
    func type() -> CalendarType? {
        return self.delegate?.type()
    }
}
