//
//  ModalDatePicker.swift
//  Calendar Ortodox
//
//  Created by MPBro on 08/07/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

class ModalDatePicker: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    var date:Date?
    var delegate: PopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func dismissPopupCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func SetTimeForNotification(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.SetDateForNotification(date: GetSelectedDate())
        }
        dismiss(animated: true, completion: nil)
    }
    
    func GetSelectedDate() -> Date {
        var calendar = Calendar.current
        
        let selectedDate = datePicker.date
        let selectedComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
        let selectedHour = selectedComponents.hour!
        let selectedMinute = selectedComponents.minute!
        var components = calendar.dateComponents(in: .current, from: date!)
        var returningComponents = DateComponents(calendar: calendar, timeZone: .current, year: components.year, month: components.month, day: components.day, hour: selectedHour, minute: selectedMinute)
        
        
        var returningDate = calendar.date(from: returningComponents)
        
        
        return returningDate!
    }
}
