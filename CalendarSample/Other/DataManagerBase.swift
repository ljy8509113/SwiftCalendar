//
//  DataManagerBase.swift
//  CalendarSample
//
//  Created by Murf on 2023/03/02.
//

import Foundation
import ObjectMapper

class DataManagerBase: NSObject {
    static let shared = DataManagerBase()
    let dateTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
        if let date = value?.toISODate()?.date {
            return date
        } else if let date = value?.toDate(style: .custom("yyyyMMddHHmmss"))?.date {
            return date
        } else {
            return value?.toDate(style: .custom("yyyyMMdd"))?.date
        }
    }, toJSON: { (value: Date?) -> String? in
        // transform value from Int? to String?
        if let date = value {
            return date.toISO()
        }
        return nil
    })
}
