//
//  ViewController.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/13.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.calendarView.setup(selectDate: Date(), type: .monthAndWeek, callbackSelect: { [weak self] date in
            
        })
        
    }
    
}


