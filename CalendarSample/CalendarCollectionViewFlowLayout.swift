//
//  CalendarCollectionViewFlowLayout.swift
//  CalendarSample
//
//  Created by jeong lee on 2023/02/22.
//

import UIKit

class CalendarCollectionViewFlowLayout: UICollectionViewFlowLayout {
    //MARK:- properties
    
    //sticky(스크롤 되어도 상위 고정) 되어야 할 item의 index
    var calendarIndex: IndexPath? {
        didSet {
            invalidateLayout()
        }
    }
    
    var filterHeaderIndex: IndexPath? {
        didSet {
            invalidateLayout()
        }
    }
    
    var filterIndex: IndexPath? {
        didSet {
            invalidateLayout()
        }
    }
    
    var calendarType: CalendarType = .monthAndWeek
    
    //MARK:- init
    required init(type: CalendarType) {
        super.init()
        self.calendarType = type
        self.filterHeaderIndex = type.filterHeaderIndex()
        self.filterIndex = type.filterIndex()
        self.calendarIndex = type.calendarIndex()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK:- override func
    // 스크롤 할 때마다 layout 재설정
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        if let filterHeader = getAttributes(at: self.filterHeaderIndex) {
            layoutAttributes?.append(filterHeader)
        }
        
        if let filterAttr = getAttributes(at: self.filterIndex) {
            layoutAttributes?.append(filterAttr)
        }
        
        if let calenarAttr = getAttributes(at: self.calendarIndex) {
            layoutAttributes?.append(calenarAttr)
        }
        
        return layoutAttributes
    }
    
    private func getAttributes(at indexPath: IndexPath?) -> UICollectionViewLayoutAttributes? {
        //stickyIndex에 해당하는 item의 layoutAttributes을 받음
        guard let collectionView = collectionView,
              let stickyIndexPath = indexPath,
              let stickyAttributes = collectionView.layoutAttributesForItem(at: stickyIndexPath)
              else {
            return nil
        }
        
        let offsetY = collectionView.contentOffset.y
        var frame = stickyAttributes.frame
        
        if stickyIndexPath == self.filterHeaderIndex {
            if frame.minY < offsetY {
                frame.origin.y = offsetY
                
                stickyAttributes.zIndex = 1
                stickyAttributes.frame = frame
                return stickyAttributes
            }
        } else if stickyIndexPath == self.filterIndex {
            var y = offsetY
            if let filterHeader = self.filterHeaderIndex, let attr = collectionView.layoutAttributesForItem(at: filterHeader) {
                y += attr.frame.size.height
            }
            
            if frame.minY < y {
                frame.origin.y = y
                stickyAttributes.zIndex = 1
                stickyAttributes.frame = frame
                return stickyAttributes
            }
        } else if stickyIndexPath == self.calendarIndex {
            var topArea: CGFloat = 0.0
            if let filterHeader = self.filterHeaderIndex, let attr = collectionView.layoutAttributesForItem(at: filterHeader) {
                topArea = attr.frame.size.height
            }
            
            if let filter = self.filterIndex, let attr = collectionView.layoutAttributesForItem(at: filter) {
                topArea += attr.frame.size.height
            }
            
            topArea += offsetY
            if topArea > stickyAttributes.frame.minY {
                var weekHeight = 60.0
                var monthHeight = weekHeight * 7.0
                
                if let cell = collectionView.cellForItem(at: stickyIndexPath) as? CalendarMonthContainerCell {
                    weekHeight = cell.getModeHeight(status: .week)
                    monthHeight = cell.getModeHeight(status: .month)
                }
                
                frame.origin.y = topArea
                var height = monthHeight - offsetY
                
                if height <= weekHeight {
                    height = weekHeight
                } else if height >= monthHeight {
                    height = monthHeight
                }
                
                frame.size.height = height
                
                stickyAttributes.zIndex = 1
                stickyAttributes.frame = frame
                return stickyAttributes
            }
        } else {
            return nil
        }
        
        return nil
    }    
}
