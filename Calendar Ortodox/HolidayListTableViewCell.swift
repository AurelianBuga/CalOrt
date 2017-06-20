//
//  HolidayListTableViewCell.swift
//  Calendar Ortodox
//
//  Created by MPBro on 20/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

class HolidayListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
