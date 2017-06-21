//
//  TableViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 16/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController , ExpandableHeaderViewDelegate {

    
    @IBOutlet var holidaysTableView: UITableView!
    

    let formatter = DateFormatter()
    var viewController = ViewController()
    
    var sections = [
        Section(month: "Ianuarie", holidays: [], expanded: false , loaded: false),
        Section(month: "Februarie", holidays: [], expanded: false , loaded: false),
        Section(month: "Martie", holidays: [], expanded: false , loaded: false),
        Section(month: "Aprilie", holidays: [], expanded: false , loaded: false),
        Section(month: "Mai",  holidays: [], expanded: false , loaded: false),
        Section(month: "Iunie", holidays: [], expanded: false , loaded: false),
        Section(month: "Iulie", holidays: [], expanded: false , loaded: false),
        Section(month: "August", holidays: [], expanded: false , loaded: false),
        Section(month: "Septembrie", holidays: [], expanded: false , loaded: false),
        Section(month: "Octombrie", holidays: [], expanded: false , loaded: false),
        Section(month: "Noiembrie", holidays: [], expanded: false , loaded: false),
        Section(month: "Decembrie", holidays: [], expanded: false , loaded: false)
    ]
    
    override func loadView() {
        super.loadView()

        //load holidays
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //LoadHolidays()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        holidaysTableView.rowHeight = UITableViewAutomaticDimension
        holidaysTableView.estimatedRowHeight = 200
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].holidays.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {        
        if !sections[indexPath.section].expanded {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header  = ExpandableHeaderView()
        header.customInit(title: sections[section].month, section: section, delegate: self)
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = sections[indexPath.section].holidays[indexPath.row].date
        let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCell") as! HolidayListTableViewCell
        let holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: sections[indexPath.section].holidays[indexPath.row].holiday, date: date!)
        let holiday =  viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
        cell.holidayLabel.attributedText = holiday
        let calendar = Calendar.current
        cell.dateLabel.text = String(calendar.component(.day, from: date!)) + ", " + viewController.GetWeekDayName(date: date!)
        return cell
    }

    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        
        if !sections[section].loaded {
            LoadHolidays(monthNo: section + 1)
            tableView.reloadSections(IndexSet(integersIn: section...section), with: .automatic)
            sections[section].loaded = true
        } else {
            tableView.reloadSections(IndexSet(integersIn: section...section), with: .automatic)
        }
    }
    
    func calculateHeight(inString:String) -> CGFloat
    {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 192.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    func LoadAllHolidays() {
        for i in 1 ..< 13 {
            LoadHolidays(monthNo: i)
        }
    }
    
    func LoadHolidays(monthNo: Int) {
        formatter.dateFormat = "yyyy MM dd"
        
        //generate string dates for this month
        var dateString:String = String("2017 " + String(monthNo) + " 1")
        var date:Date = formatter.date(from: dateString)!
        var dateComponent = DateComponents()
        
        var nextMonthDate:Date
        
        dateComponent.month = 1
        nextMonthDate = Calendar.current.date(byAdding: dateComponent, to: date)!
        dateComponent.month = 0
        
        dateComponent.day = 1
        
        while let holidayString:String? =  viewController.GetHolidayStringByDateString(dateString: dateString) {
            if holidayString != "" && date < nextMonthDate {
                var holidayStr = HolidayStr(holiday: holidayString!, date: date)
                sections[monthNo - 1].holidays.append(holidayStr)
                date = Calendar.current.date(byAdding: dateComponent, to: date)!
                dateString = viewController.ConvertDateToString(date: date)!
            } else {
                break
            }
        }
    }
    
    
    @IBAction func GoToCurrentDate(_ sender: Any) {
        var currentDate = Date()
        let calendar = Calendar.current
        var currentMonth = calendar.component(.month, from: currentDate)
        var currentDay = calendar.component(.day, from: currentDate)
        toggleSection(header: ExpandableHeaderView(), section: currentMonth - 1)
        var indexPath = IndexPath(row: currentDay, section: currentMonth - 1)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
    }
    
    
    @IBAction func SetNotification(_ sender: Any) {
        //get date
        if let indexPath = tableView.indexPathForSelectedRow {
            var date = sections[indexPath.section].holidays[indexPath.row].date
            viewController.selectedHoliday = HolidayStr()
            viewController.setSelectedHoliday(holiday: sections[indexPath.section].holidays[indexPath.row].holiday)
            viewController.setSelectedDate(date: sections[indexPath.section].holidays[indexPath.row].date)
            viewController.SetNotification(date: date!)
        } else {
            //alert user that a selection is needed
            createAlert(title: "Alertă" , message: "Pentru a putea seta o notificare este necesar să selectati o zi.")
        }
    }
    
    func createAlert(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    

}
