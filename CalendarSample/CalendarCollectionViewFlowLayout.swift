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
    
    var filterIndex: IndexPath? {
        didSet {
            invalidateLayout()
        }
    }
    
    //MARK:- init
    required init(filterIndex: IndexPath?, calendarIndex: IndexPath?) {
        super.init()
//        self.stickyIndexPath = stickyIndexPath
        self.filterIndex = filterIndex
        self.calendarIndex = calendarIndex
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
        
        if let filterAttr = getFilterAttributes(at: self.filterIndex) {
            layoutAttributes?.append(filterAttr)
        }
        
        if let calenarAttr = getCalendarAttributes(at: self.calendarIndex) {
            layoutAttributes?.append(calenarAttr)
        }
        
        return layoutAttributes
    }
    
    private func getFilterAttributes(at indexPath: IndexPath?) -> UICollectionViewLayoutAttributes? {
        //stickyIndex에 해당하는 item의 layoutAttributes을 받음
        guard let collectionView = collectionView,
              let stickyIndexPath = indexPath,
              let stickyAttributes = collectionView.layoutAttributesForItem(at: stickyIndexPath)
              else {
            return nil
        }
        
        let headerHeight = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first?.frame.size.height ?? 0.0
        
        if collectionView.contentOffset.y > stickyAttributes.frame.minY - headerHeight {
            var frame = stickyAttributes.frame
            frame.origin.y = collectionView.contentOffset.y + headerHeight
//            frame.size.height = height
            stickyAttributes.frame = frame
            
            stickyAttributes.zIndex = 2
            return stickyAttributes
        }
        return nil
    }
    
    //MARK:- private func
    private func getCalendarAttributes(at indexPath: IndexPath?) -> UICollectionViewLayoutAttributes? {
        //stickyIndex에 해당하는 item의 layoutAttributes을 받음
        guard let collectionView = collectionView,
              let stickyIndexPath = indexPath,
              let stickyAttributes = collectionView.layoutAttributesForItem(at: stickyIndexPath)
              else {
            return nil
        }
        
        // 받아온 layoutAttributes의 minY 값보다 더 scroll 된다면,
        // 1. 해당 attribute의 y값 조정을 통해 collectionView의 상위에 sticky 되어있는 것처럼 보이게하고,
        // 2. zIndex 조절을 통해 z축 상위로 올림.
        
        let offsetY = collectionView.contentOffset.y
        var topArea: CGFloat = 0.0
        var filterArea: CGFloat = 0.0
        if let filter = self.filterIndex, let attr = collectionView.layoutAttributesForItem(at: filter) {
            let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let headerHeight = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first?.frame.size.height ?? 0.0
            let space = flow?.minimumLineSpacing ?? 0.0
            filterArea = attr.frame.size.height + headerHeight + space
            topArea = filterArea + offsetY
            
            print("\(headerHeight). :: \(filterArea) topArea : \(topArea) :: \(stickyAttributes.frame.minY)")
        }
        
        if topArea > stickyAttributes.frame.minY {
            var weekHeight = 60.0
            var monthHeight = weekHeight * 7.0
            
            if let cell = collectionView.cellForItem(at: stickyIndexPath) as? CalendarMonthContainerCell {
                weekHeight = cell.getModeHeight(status: .week)
                monthHeight = cell.getModeHeight(status: .month)
            }
            
            var frame = stickyAttributes.frame
            frame.origin.y = topArea
            var height = monthHeight - offsetY
            print("attr : \(height)")
            if height <= weekHeight {
                height = weekHeight
            } else if height >= monthHeight {
                height = monthHeight
            }
            frame.size.height = height
            stickyAttributes.frame = frame
            
            stickyAttributes.zIndex = 1
            return stickyAttributes
        }
        return nil
    }
    
}
