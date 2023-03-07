//
//  ViewController.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/13.
//

import UIKit
import ObjectMapper

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var anMainView: ANMainCalendarView!
    
    var date: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var events: [ArtistNewsEventObject]?
        if let path = Bundle.main.path(forResource: "test", ofType: "json") {
            do {
                let jsonStr = try String(contentsOfFile: path)
                
                    let obj = ArtistNewsCalendarObject(JSONString: jsonStr)
                    events = obj?.events
                    print("")
                
            } catch {
                print("error : \(error)")
            }
        }
        
//        self.calendarView.setup(startDate: nil,
//                                selectDate: Date(),
//                                type: .monthAndWeek,
//                                events: events,
//                                cellHeight: 80.0,
//                                callbackSelect: { [weak self] date in
//            if self?.date.isSameMonth(date: date) == false {
//
//            }
//        })
        
        self.anMainView.setup(startDate: nil,
                              selectDate: Date(),
                              events: events,
                              cellHeight: 80.0,
                              callbackSelect: { [weak self] date in
            
            
            
        })
        
    }
    
}


