//
//  Common.swift
//  CalendarSample
//
//  Created by jeong lee on 2023/02/17.
//

import Foundation
import UIKit

enum CalendarStatus {
    case month
    case week
    case changing
}

enum CalendarMoveType {
    case today
    case previous
    case next
}

enum CalendarType {
    case onlyMonth
    case onlyWeek
    case monthAndWeek
    
    func filterHeaderIndex() -> IndexPath? {
        switch self {
        case .monthAndWeek :
            return IndexPath(row: 0, section: 0)
        default:
            return nil
        }
    }
    
    func filterIndex() -> IndexPath? {
        switch self {
        case .monthAndWeek :
            return IndexPath(row: 1, section: 0)
        default:
            return nil
        }
    }
    
    func calendarIndex() -> IndexPath {
        switch self {
        case .monthAndWeek :
            return IndexPath(row: 2, section: 0)
        default:
            return IndexPath(row: 0, section: 0)
        }
    }
    
    func topArea(collectionView: UICollectionView) -> CGFloat {
        switch self {
        case .monthAndWeek:
            let header = collectionView.cellForItem(at: filterHeaderIndex()!)?.frame.size.height ?? 40.0
            let filter = collectionView.cellForItem(at: filterIndex()!)?.frame.size.height ?? 100.0
            
            return header + filter
        default:
            return 0.0
        }
    }
}

public enum ArtistNewsUpdateType: String {
    case all, sns, anniversary, release, contents, other = "etc"
    case broadcast, show, event, purchase, vote
    
//    var text: String {
//        switch self {
//        case .all:
//            return "clip_category_all".localized
//        case .sns:
//            return "artist_update_type_sns".localized
//        case .news:
//            return "artist_update_type_news".localized
//        case .schedule:
//            return "artist_update_type_schedule".localized
//        case .contents:
//            return "artist_update_type_contents".localized
//        default: // other ..
//            return "artist_type_etc".localized
//        }
//    }
//
    var imageName: String {
        switch self {
        case .sns:
            return "iconSns1"
        case .anniversary:
            return "iconNews1"
        case .event:
            return "iconShedule1"
        case .contents:
            return "iconContents1"
        default: // other ..
            return "iconOther"
        }
    }
}
