//
//  PrayerViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 01/07/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

class PrayerViewController: UIViewController {
    
    var name:String!
    var body:String!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var BodyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        TitleLabel.text = name
        BodyLabel.text = body
        BodyLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ZoomIn(_ sender: Any) {
        if BodyLabel.font.pointSize < 19 {
            TitleLabel.font = UIFont.systemFont(ofSize: TitleLabel.font.pointSize + 1)
            BodyLabel.font = UIFont.systemFont(ofSize: BodyLabel.font.pointSize + 1)
        }
        
    }
    
    @IBAction func ZoomOut(_ sender: Any) {
        if BodyLabel.font.pointSize > 11 {
            TitleLabel.font = UIFont.systemFont(ofSize: TitleLabel.font.pointSize - 1)
            BodyLabel.font = UIFont.systemFont(ofSize: BodyLabel.font.pointSize - 1)
        }
        
    }
}
