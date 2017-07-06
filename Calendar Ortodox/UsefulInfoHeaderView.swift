//
//  UsefulInfoHeaderView.swift
//  Calendar Ortodox
//
//  Created by MPBro on 05/07/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

class UsefulInfoHeaderView: UITableViewHeaderFooterView {
    var section:Int!

    func customInit(title:String , section: Int ) {
        var attrString = NSMutableAttributedString(string: title)
        var range = title.range(of: title)
        attrString.addAttribute(NSFontAttributeName , value: UIFont.systemFont(ofSize: 10.0), range: title.nsRange(from: range!))
        textLabel?.attributedText = attrString
        self.section = section
    }

}
