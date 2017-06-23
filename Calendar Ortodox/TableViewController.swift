//
//  TableViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 16/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController , ExpandableHeaderViewDelegate , UISearchResultsUpdating , UISearchBarDelegate {

    
    @IBOutlet var holidaysTableView: UITableView!
    @IBOutlet var TodayButton: UIBarButtonItem!
    @IBOutlet var NotificationButton: UIBarButtonItem!
    
    var searchController : UISearchController!
    var activityIndicatorView: UIActivityIndicatorView!

    let formatter = DateFormatter()
    var viewController = ViewController()
    
    var highlightedSearchRanges = [
        [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>](), [Range<String.Index>]()
    ]
    
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
    
    var filteredSections = [Section]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if sections[0].holidays.count == 0 {
            activityIndicatorView.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                OperationQueue.main.addOperation() {
                    self.LoadAllHolidays()
                    self.activityIndicatorView.stopAnimating()
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
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
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = activityIndicatorView
        
        holidaysTableView.rowHeight = UITableViewAutomaticDimension
        holidaysTableView.estimatedRowHeight = 200
        
        self.searchController = UISearchController(searchResultsController: nil)
        //self.holidaysTableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.sizeToFit()
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Caută"
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.titleView = self.searchController.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        
        if searchString == "" {
            filteredSections = sections
        } else {
            var i = 0
            filteredSections.removeAll() // is mandatory to empty the filtered array
            for section in sections {
                //var filteredContent = section.holidays.filter { $0.holiday.range(of: searchString) != nil }
                var filteredContent = [HolidayStr]()
                highlightedSearchRanges[i].removeAll()
                for holiday in section.holidays {
                    var date = holiday.date
                    var holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: holiday.holiday, date: date!)
                    let holidayWithAttr = viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
                    
                    
                    if holidayWithAttr.string.contains(searchString) {
                        highlightedSearchRanges[i].append(holidayWithAttr.string.range(of: searchString)!)
                        filteredContent.append(holiday)
                    }
                }
                filteredSections.append(Section(month: section.month , holidays : filteredContent , expanded: true , loaded: true))
                i += 1
            }
        }
        
        var sectionIndex = (filteredSections.count == 0 ? 0 : filteredSections.count - 1)
        tableView.reloadData()
        tableView.reloadSections(IndexSet(integersIn: 0...sectionIndex), with: .automatic)
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
        if searchController.isActive && searchController.searchBar.text != "" {
            if filteredSections[section].expanded {
                return filteredSections[section].holidays.count
            } else {
                return 0
            }
        } else {
            if sections[section].expanded {
                return sections[section].holidays.count
            } else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isActive && searchController.searchBar.text != "" {
            if !filteredSections[indexPath.section].expanded {
                return 0
            } else {
                return UITableViewAutomaticDimension
            }
        } else {
            if !sections[indexPath.section].expanded {
                return 0
            } else {
                return UITableViewAutomaticDimension
            }
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(NotificationButton, animated: true)
        self.navigationItem.setLeftBarButton(TodayButton, animated: true)
        self.searchController.searchBar.sizeToFit()
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sectionIndexTitlesArray: [String] = []
        for var section in sections {
            sectionIndexTitlesArray.append(section.month[0])
        }
        
        return sectionIndexTitlesArray
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
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
        let date: Date
        let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCell") as! HolidayListTableViewCell
        //let holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: sections[indexPath.section].holidays[indexPath.row].holiday, date: date!)
        //let holiday =  viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
        let holidayWithoutDate: String!
        if searchController.isActive && searchController.searchBar.text != "" {
            date = filteredSections[indexPath.section].holidays[indexPath.row].date
            holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: filteredSections[indexPath.section].holidays[indexPath.row].holiday, date: date)
        } else {
            date  =  sections[indexPath.section].holidays[indexPath.row].date
            holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: sections[indexPath.section].holidays[indexPath.row].holiday, date: date)
        }
        
        let holiday = viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.holidayLabel.attributedText = highlightSearchedText(holiday: holiday , indexPath: indexPath)
        } else {
            cell.holidayLabel.attributedText = holiday
        }
        
        let calendar = Calendar.current
        cell.dateLabel.text = String(calendar.component(.day, from: date)) + ", " + viewController.GetWeekDayName(date: date)
        return cell
    }
    
    func highlightSearchedText(holiday: NSMutableAttributedString , indexPath : IndexPath) -> NSMutableAttributedString {
        holiday.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: holiday.string.nsRange(from: highlightedSearchRanges[indexPath.section][indexPath.row]))
        
        return holiday
    }

    func toggleSection(header: ExpandableHeaderView, section: Int) {
        if searchController.isActive && searchController.searchBar.text != "" {
            filteredSections[section].expanded = !filteredSections[section].expanded
        } else {
            sections[section].expanded = !sections[section].expanded
        }
        
        tableView.reloadSections(IndexSet(integersIn: section...section), with: .automatic)
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
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)
        
        if !sections[currentMonth - 1].expanded {
            toggleSection(header: ExpandableHeaderView(), section: currentMonth - 1)
        }
        
        let indexPath = IndexPath(row: currentDay, section: currentMonth - 1)
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

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}

extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        let lower = UTF16View.Index(range.lowerBound, within: utf16)
        let upper = UTF16View.Index(range.upperBound, within: utf16)
        return NSRange(location: utf16.startIndex.distance(to: lower), length: lower.distance(to: upper))
    }
}
