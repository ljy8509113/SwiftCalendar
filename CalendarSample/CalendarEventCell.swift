//
//  CalendarEventCell.swift
//  CalendarSample
//
//  Created by Murf on 2023/02/14.
//

import UIKit

class CalendarEventCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    var data: ArtistNewsEventObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(data: ArtistNewsEventObject?) {
        self.backgroundColor = .yellow
        label.text = data?.title ?? ""
    }

}
