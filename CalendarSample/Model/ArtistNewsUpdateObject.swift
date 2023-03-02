//
//  ArtistNewsEventObject.swift
//  mubeat
//
//  Created by HyunJoon Ko on 2021/10/13.
//  Copyright © 2021 Vlending Co., Ltd. All rights reserved.
//

import UIKit
import SwiftDate
import ObjectMapper

class ArtistNewsTagObject: Mappable {
    
    var tagType: ArtistNewsUpdateType?
    var memberIdentifier: String?
    var tagName: String?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        tagType <- map["tag_code"]
        if tagType == nil {
            memberIdentifier <- map["tag_code"]
        }
        tagName <- map["tag_name"]
    }
}

class ArtistNewsFilterObject: Mappable {
    
    var tags: [ArtistNewsTagObject]?
    var members: [ArtistNewsTagObject]?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        tags <- map["tags"]
        members <- map["members"]
    }
}

// 캘린더 정보만 가져오는 API 구성시 사용
class ArtistNewsEventBaseObject: ArtistNewsFilterObject {
    
    var identifier: Int?
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var isAllDay: Bool?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        identifier <- map["news_id"]
        title <- map["title"]
        startDate <- (map["start_date"], DataManagerBase.shared.dateTransform)
        endDate <- (map["end_date"], DataManagerBase.shared.dateTransform)
        isAllDay <- map["is_all_day"]
    }
}

// 캘린더와 이벤트 상세 정보 구성시 사용
class ArtistNewsEventObject: ArtistNewsEventBaseObject {
    
    var contents: String?
    var path: String?
    var place: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        contents <- map["contents"]
        path <- map["detail_link"]
        place <- map["place"]
        path = "https://mubeat.page.link/mubeat_2022_artist"
    }
}

// 캘린더 메인
class ArtistNewsCalendarObject: Mappable {
    
    var events: [ArtistNewsEventObject]?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        events <- map["events"]
    }
}

// 아티스트 채널 및 아티스트 홈 (주별 캘린더)
class ArtistNewsChannelObject: Mappable {
    
    var events: [ArtistNewsEventObject]?
    var startDate: Date?
    var endDate: Date?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        events <- map["newsweek"]
        startDate <- (map["start_date"], DataManagerBase.shared.dateTransform)
        endDate <- (map["end_date"], DataManagerBase.shared.dateTransform)
    }
}
