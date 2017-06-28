//
//  TableViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 16/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import UserNotifications

class TableViewController: UITableViewController , ExpandableHeaderViewDelegate , UISearchResultsUpdating , UISearchBarDelegate {

    
    @IBOutlet var holidaysTableView: UITableView!
    @IBOutlet var TodayButton: UIBarButtonItem!
    @IBOutlet var NotificationButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LoadingText: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var searchController : UISearchController!

    let formatter = DateFormatter()
    var viewController = ViewController()
    
    var selectedHoliday:HolidayStr?
    
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
    

    
    override func loadView() {
        super.loadView()
        //load holidays
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredSections = sections

        if filteredSections[11].holidays.count == 0 {
            segmentControl.isHidden = true
            activityIndicator.startAnimating()
            activityIndicator.backgroundColor = UIColor.white
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.LoadAllHolidays()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.LoadingText.isHidden = true
                self.segmentControl.isHidden = false
                
                self.tableView.reloadData()
            }
        }
        
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
            switch segmentControl.selectedSegmentIndex {
            case 0:
                filteredSections = sections
                break
            case 1:
                filteredSections = GetCrossTypeHolidays(crossType: CrossType.black)
                break
            case 2:
                filteredSections = GetCrossTypeHolidays(crossType: CrossType.blue)
                break
            case 3:
                filteredSections = GetCrossTypeHolidays(crossType: CrossType.red)
                break
            default:
                filteredSections = sections
                break
            }
        } else {
            var i = 0
            filteredSections.removeAll() // is mandatory to empty the filtered array
            var crossSelectedSections: [Section] = []
            switch segmentControl.selectedSegmentIndex {
            case 0:
                crossSelectedSections = sections
                break
            case 1:
                crossSelectedSections = GetCrossTypeHolidays(crossType: CrossType.black)
                break
            case 2:
                crossSelectedSections = GetCrossTypeHolidays(crossType: CrossType.blue)
                break
            case 3:
                crossSelectedSections = GetCrossTypeHolidays(crossType: CrossType.red)
                break
            default:
                crossSelectedSections = sections
                break
            }
            for section in crossSelectedSections {
                //var filteredContent = section.holidays.filter { $0.holiday.range(of: searchString) != nil }
                var filteredContent = [HolidayStr]()
                highlightedSearchRanges[i].removeAll()
                for holiday in section.holidays {
                    var date = holiday.date
                    var holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: holiday.holiday, date: date!)
                    let holidayWithAttr = viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
                    
                    
                    if holidayWithAttr.string.lowercased().contains(searchString.lowercased()) {
                        highlightedSearchRanges[i].append(holidayWithAttr.string.lowercased().range(of: searchString.lowercased())!)
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
            if filteredSections[section].expanded {
                return filteredSections[section].holidays.count
            } else {
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if !filteredSections[indexPath.section].expanded {
                return 0
            } else {
                return UITableViewAutomaticDimension
            }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(NotificationButton, animated: true)
        //self.searchController.searchBar.sizeToFit()
        self.navigationItem.setLeftBarButton(TodayButton, animated: true)
        
        self.SegmentControlChanged(self)
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
    
    
    func GetCrossTypeHolidays(crossType: CrossType) -> [Section] {
        var sectionCrossType: Section
        var result: [Section] = []
        for section in sections {
            var resultHolidays: [HolidayStr] = []
            for holiday in section.holidays {
                for crossTypeX in holiday.crossTypes {
                    if crossTypeX == crossType {
                        resultHolidays.append(holiday)
                        break
                    }
                }
            }
            sectionCrossType = section
            sectionCrossType.holidays = resultHolidays
            result.append(sectionCrossType)
        }
        
        return result
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date: Date
        let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCell") as! HolidayListTableViewCell
        //let holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: sections[indexPath.section].holidays[indexPath.row].holiday, date: date!)
        //let holiday =  viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
        let holidayWithoutDate: String!
            date = filteredSections[indexPath.section].holidays[indexPath.row].date
            holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: filteredSections[indexPath.section].holidays[indexPath.row].holiday, date: date)
        
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedHoliday = filteredSections[indexPath.section].holidays[indexPath.row]
    }
    
    func highlightSearchedText(holiday: NSMutableAttributedString , indexPath : IndexPath) -> NSMutableAttributedString {
        holiday.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: holiday.string.nsRange(from: highlightedSearchRanges[indexPath.section][indexPath.row]))
        
        return holiday
    }

    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        filteredSections[section].expanded = !filteredSections[section].expanded
        
        tableView.reloadSections(IndexSet(integersIn: section...11), with: .automatic)
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
        
        filteredSections = sections
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
                var crossTypes: [CrossType] = []
                if holidayHasRedCross(holiday: holidayString!) {
                    crossTypes.append(CrossType.red)
                }
                if holidayHasBlueCross(holiday: holidayString!) {
                    crossTypes.append(CrossType.blue)
                }
                if holidayHasBlackCross(holiday: holidayString!) {
                            crossTypes.append(CrossType.black)
                }
                if crossTypes.count == 0 {
                    crossTypes.append(CrossType.none)
                }
                
                
                
                var holidayStr = HolidayStr(holiday: holidayString!, date: date , crossTypes: crossTypes)
                sections[monthNo - 1].holidays.append(holidayStr)
                date = Calendar.current.date(byAdding: dateComponent, to: date)!
                dateString = viewController.ConvertDateToString(date: date)!
            } else {
                break
            }
        }
    }
    
    func holidayHasRedCross(holiday: String) -> Bool {
        var holidayVar = holiday
        
        while let crossRange = holidayVar.range(of: "†") {
            var holidayVar2 = holidayVar
            while let startTagRange = holidayVar2.range(of: "<r>") , let endTagRange = holidayVar2.range(of: "</r>") {
                if (startTagRange != nil) && (endTagRange != nil) && (crossRange != nil) {
                    if (startTagRange.upperBound) <= (crossRange.lowerBound) && (endTagRange.lowerBound) >= (crossRange.upperBound) {
                        return true
                    }
                }
                
                holidayVar2.removeSubrange(startTagRange)
                holidayVar2.removeSubrange(holidayVar2.range(of: "</r>")!)
            }
            
            holidayVar.removeSubrange(crossRange)
        }
        
        return false
    }
    
    func holidayHasBlueCross(holiday: String) -> Bool {
        var holidayVar = holiday
        
        while let crossRange = holidayVar.range(of: "†") {
            var holidayVar2 = holidayVar
            while let startTagRange = holidayVar2.range(of: "<a>") , let endTagRange = holidayVar2.range(of: "</a>") {
                if (startTagRange != nil) && (endTagRange != nil) && (crossRange != nil) {
                    if (startTagRange.upperBound) <= (crossRange.lowerBound) && (endTagRange.lowerBound) >= (crossRange.upperBound) {
                        return true
                    }
                }
                
                holidayVar2.removeSubrange(startTagRange)
                holidayVar2.removeSubrange(holidayVar2.range(of: "</a>")!)
            }
            
            holidayVar.removeSubrange(crossRange)
        }
        
        return false
    }
    
    func holidayHasBlackCross(holiday: String) -> Bool {
        var holidayVar = holiday
        
        while let startRedRange = holidayVar.range(of: "<r>"), let endRedRange = holidayVar.range(of: "</r>") {
            holidayVar.removeSubrange(startRedRange.lowerBound..<endRedRange.upperBound)
        }
        
        while let startBlueRange = holidayVar.range(of: "<a>") , let endBlueRange = holidayVar.range(of: "</a>") {
            holidayVar.removeSubrange(startBlueRange.lowerBound..<endBlueRange.upperBound)
        }
        
        if let crossRange = holidayVar.range(of: "†") {
            return true
        } else {
            return false
        }
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    func scheduleNotification(at date: Date) {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute! + 1)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Notificare"
        content.body = (selectedHoliday?.holiday)!
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        content.sound = UNNotificationSound.default()
        
        formatter.dateFormat = "yyyy MM dd"
        
        let request = UNNotificationRequest(identifier: "holiday_" + formatter.string(from: (selectedHoliday?.date)!), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }


    
    func SetNotification(date: Date) {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else {
                        self.createAlert(title: "Alertă" , message: "Pentru a putea activa această funcționalitate ar trebui sa permiți aplicației Calendar Ortodox să trimită notificări. Pentru a face asta te rog du-te pe dispozitivul tău in Setări -> Calendar Ortodox -> Notificări și selectează ON la opțiunea Permite notificări.")
                        return
                    }
                    
                    // Schedule Local Notification
                    self.scheduleNotification(at: Date()) //test
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleNotification(at: Date()) //test
            case .denied:
                self.createAlert(title: "Alertă" , message: "Pentru a putea activa această funcționalitate ar trebui sa permiți aplicației Calendar Ortodox să trimită notificări. Pentru a face asta te rog du-te pe dispozitivul tău in Setări -> Calendar Ortodox -> Notificări și selectează ON la opțiunea Permite notificări.")
            }
        }
    }

    
    func createAlert(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    
    @IBAction func GoToCurrentDate(_ sender: Any) {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)
        
        segmentControl.selectedSegmentIndex = 0
        SegmentControlChanged(self)
        
        if !filteredSections[currentMonth - 1].expanded {
            toggleSection(header: ExpandableHeaderView(), section: currentMonth - 1)
        }
        
        let when = DispatchTime.now() + 0.3 // select the cell with a delay of 0.3 seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            let indexPath = IndexPath(row: currentDay, section: currentMonth - 1)
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }
        
    }
    
    
    @IBAction func SetNotification(_ sender: Any) {
        //get date
        if let indexPath = tableView.indexPathForSelectedRow {
            var date = filteredSections[indexPath.section].holidays[indexPath.row].date
            SetNotification(date: date!)
        } else {
            //alert user that a selection is needed
            createAlert(title: "Alertă" , message: "Pentru a putea seta o notificare este necesar să selectati o zi.")
        }
    }
    
    
    @IBAction func SegmentControlChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            filteredSections = sections
            break
        case 1:
            filteredSections = GetCrossTypeHolidays(crossType: CrossType.black)
            break
        case 2:
            filteredSections = GetCrossTypeHolidays(crossType: CrossType.blue)
            break
        case 3:
            filteredSections = GetCrossTypeHolidays(crossType: CrossType.red)
            break
        default:
            filteredSections = sections
            break
        }
        
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            updateSearchResults(for: self.searchController)
        }
        
        self.tableView.reloadData()
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
