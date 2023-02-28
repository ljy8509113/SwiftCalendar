//
//  CalendarEventCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/14.
//

import UIKit

class CalendarEventCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(row: Int) {
        self.backgroundColor = .yellow
        label.text = "\(row)"
    }

}
