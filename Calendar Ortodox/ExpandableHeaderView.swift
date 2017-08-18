//
//  ExpandableHeaderView.swift
//  Calendar Ortodox
//
//  Created by MPBro on 15/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView , section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewDelegate?
    var section:Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target : self , action: #selector(selectHeaderAction)))
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as? ExpandableHeaderView
        delegate?.toggleSection(header: cell!, section: (cell?.section)!)
    }
    
    func customInit(title:String , section: Int , delegate: ExpandableHeaderViewDelegate) {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }

}
