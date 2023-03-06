//
//  Common.swift
//  CalendarSample
//
//  Created by jeong lee on 2023/02/17.
//

import Foundation

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
}

class Common: NSObject {
    static let CELL_HEIGHT = 60.0
}



///////////
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
