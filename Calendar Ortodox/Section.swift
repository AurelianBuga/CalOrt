//
//  Section.swift
//  Calendar Ortodox
//
//  Created by MPBro on 15/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import Foundation

enum CrossType {
    case red
    case blue
    case black
    case none
}

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
    var crossTypes: [CrossType]!
    
    init(holiday: String , date: Date , crossTypes: [CrossType]) {
        self.holiday = holiday
        self.date = date
        self.crossTypes = crossTypes
    }
    
    init() {
        
    }
}
