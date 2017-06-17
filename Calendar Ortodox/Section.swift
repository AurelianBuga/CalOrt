//
//  Section.swift
//  Calendar Ortodox
//
//  Created by MPBro on 15/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import Foundation

struct Section {
    var month:String!
    var holidays:[HolidayStr]!
    var expanded: Bool!
    var loaded: Bool!

    init(month:String , holidays:[HolidayStr] , expanded: Bool , loaded: Bool) {
        self.month = month
        self.holidays = holidays
        self.expanded = expanded
        self.loaded = loaded
    }
}

struct HolidayStr {
    var holiday: String!
    var date: Date!
    
    init(holiday: String , date: Date) {
        self.holiday = holiday
        self.date = date
    }
}
