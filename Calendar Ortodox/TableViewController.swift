//
//  TableViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 16/06/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TableViewController: UITableViewController , ExpandableHeaderViewDelegate , UISearchResultsUpdating , UISearchBarDelegate , GADInterstitialDelegate , GADNativeExpressAdViewDelegate {
    var adsToLoad = [GADNativeExpressAdView]()
    let adInterval = 5
    let adViewHeight = CGFloat(80)
    
    @IBOutlet var holidaysTableView: UITableView!
    @IBOutlet var TodayButton: UIBarButtonItem!
    @IBOutlet var NotificationButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LoadingText: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var ExpandCollapseAllButton: UIBarButtonItem!
    
    var searchController : UISearchController!

    let formatter = DateFormatter()
    var viewController = ViewController()
    
    var selectedHoliday:HolidayStr?
    var areAllExpanded: Bool?
    
    
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
    
    var interstitialAd: GADInterstitial?

    
    override func loadView() {
        super.loadView()
        //load holidays
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredSections = sections
        areAllExpanded = false

        if filteredSections[11].holidays.count == 0 {
            segmentControl.isHidden = true
            activityIndicator.startAnimating()
            activityIndicator.backgroundColor = UIColor.white
            
            // Translucency of the navigation bar is disabled so that it matches with
            // the non-translucent background of the extension view.
            //navigationController!.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.isTranslucent = false
            
            // The navigation bar's shadowImage is set to a transparent image.  In
            // addition to providing a custom background image, this removes
            // the grey hairline at the bottom of the navigation bar.  The
            // ExtendedNavBarView will draw its own hairline.
            //navigationController!.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
            //self.navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
            // "Pixel" is a solid white 1x1 image.
            //navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)
            //self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.LoadAllHolidays()
                
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.LoadingText.isHidden = true
                    self.segmentControl.isHidden = false
                    
                    self.tableView.reloadData()
                    
                    self.tableView.register(UINib(nibName: "NativeAdExpress" , bundle: nil), forCellReuseIdentifier: "NativeAdExpressCellView")
                    
                    self.AddNativeExpressAd()
                    self.LoadNextAd()
                    self.filteredSections = self.sections
                }
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
        
        interstitialAd = CreateAndLoadInterstitialAd()
    }
    
    func CreateAndLoadInterstitialAd() -> GADInterstitial {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3495703042329721/6638139128")
        interstitial.delegate = self
        interstitial.load(request)
        
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitialAd = CreateAndLoadInterstitialAd()
    }
    
    func randomNumberInRange(lower: Int , upper: Int) -> Int{
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func randomPresentationOfInterstitialAd(oneIn: Int) {
        let randomNumber = randomNumberInRange(lower: 1, upper: oneIn)
        
        if randomNumber == 1 {
            if interstitialAd != nil {
                if (interstitialAd?.isReady)! {
                    interstitialAd?.present(fromRootViewController: self)
                }
            }
        }
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
                    var date = (holiday as! HolidayStr).date
                    var holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: (holiday as! HolidayStr).holiday, date: date!)
                    let holidayWithAttr = viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
                    
                    
                    if holidayWithAttr.string.lowercased().contains(searchString.lowercased()) {
                        highlightedSearchRanges[i].append(holidayWithAttr.string.lowercased().range(of: searchString.lowercased())!)
                        filteredContent.append(holiday as! HolidayStr)
                    }
                }
                filteredSections.append(Section(month: section.month , holidays : filteredContent as! [AnyObject] , expanded: true , loaded: true))
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
        TodayButton = self.navigationItem.leftBarButtonItem
        NotificationButton = self.navigationItem.rightBarButtonItem
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationItem.setLeftBarButton(nil, animated: true)
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(NotificationButton, animated: true)
        self.navigationItem.setLeftBarButton(TodayButton, animated: true)
        self.searchController.searchBar.sizeToFit()
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
        
        var frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        var myCustomView: UIImageView = UIImageView(frame: frame)
        var myImage: UIImage
        
        myImage = UIImage(named: "right_arrow")!
        
        if sections[section].expanded {
            UIView.animate(withDuration: 0.40, animations: {
                myCustomView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 0.50))
            })
        }
        
        
        myCustomView.image = myImage
        header.addSubview(myCustomView)
        
        let trailingSpace = NSLayoutConstraint(item: header, attribute: NSLayoutAttribute.trailingMargin, relatedBy: NSLayoutRelation.equal, toItem: myCustomView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 20)
        let leadingSpace = NSLayoutConstraint(item: header, attribute: NSLayoutAttribute.leadingMargin, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: myCustomView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 100)
        let centerX = NSLayoutConstraint(item: myCustomView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: header, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: myCustomView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
        let centerY = NSLayoutConstraint(item: myCustomView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: header, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([trailingSpace  , centerY , width])
        
        myCustomView.translatesAutoresizingMaskIntoConstraints = false
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    
    func GetCrossTypeHolidays(crossType: CrossType) -> [Section] {
        var sectionCrossType: Section
        var result: [Section] = []
        for section in sections {
            var resultHolidays: [HolidayStr] = []
            for holiday in section.holidays {
                for crossTypeX in (holiday as! HolidayStr).crossTypes {
                    if crossTypeX == crossType {
                        resultHolidays.append(holiday as! HolidayStr)
                        break
                    }
                }
            }
            sectionCrossType = section
            sectionCrossType.holidays = resultHolidays as! [AnyObject]
            result.append(sectionCrossType)
        }
        
        return result
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((filteredSections[indexPath.section].holidays[indexPath.row] as? HolidayStr) != nil) {
            let date: Date
            let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCell") as! HolidayListTableViewCell
            //let holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: sections[indexPath.section].holidays[indexPath.row].holiday, date: date!)
            //let holiday =  viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
            let holidayWithoutDate: String!
            date = (filteredSections[indexPath.section].holidays[indexPath.row] as! HolidayStr).date
            holidayWithoutDate = viewController.RemoveDateFromHolidayString(holidayString: (filteredSections[indexPath.section].holidays[indexPath.row] as! HolidayStr).holiday, date: date)
            
            
            let holiday = viewController.GenerateAttributedStringHoliday(holidayString: holidayWithoutDate)
            
            if searchController.isActive && searchController.searchBar.text != "" {
                cell.holidayLabel.attributedText = highlightSearchedText(holiday: holiday , indexPath: indexPath)
            } else {
                cell.holidayLabel.attributedText = holiday
            }
            
            let calendar = Calendar.current
            cell.dateLabel.text = String(calendar.component(.day, from: date)) + ", " + viewController.GetWeekDayName(date: date)
            
            return cell
        } else {
            let adView = filteredSections[indexPath.section].holidays[indexPath.row] as! GADNativeExpressAdView
            let cell = tableView.dequeueReusableCell(withIdentifier: "NativeAdExpressCellView" , for: indexPath)
            
            for subview in cell.contentView.subviews {
                cell.willRemoveSubview(subview)
            }
            
            cell.contentView.addSubview(adView)
            adsToLoad.append(adView)
            adView.center = cell.contentView.center
            
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (filteredSections[indexPath.section].holidays[indexPath.row] as? HolidayStr != nil) {
            self.selectedHoliday = (filteredSections[indexPath.section].holidays[indexPath.row] as! HolidayStr)
            performSegue(withIdentifier: "HolidayShowDetailsSegue", sender: self)
        } else {
            let adView = filteredSections[indexPath.section].holidays[indexPath.row] as! GADNativeExpressAdView
            //adView.select(self)
        }
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
            self.LoadHolidays(monthNo: i)
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
                sections[monthNo - 1].holidays.append(holidayStr as! AnyObject)
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
        
        randomPresentationOfInterstitialAd(oneIn: 2)
        
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = tableView.indexPathForSelectedRow {
            return true
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HolidayShowDetailsSegue" {
            if selectedHoliday != nil {
                let calendar = Calendar.current
                let selectedDate = selectedHoliday?.date
                formatter.dateFormat = "MMMM"
                var holidayDetails = segue.destination as! HolidayDetailsViewController
                holidayDetails.day = viewController.GetWeekDayName(date: selectedDate!) + ","
                holidayDetails.dateString = String(calendar.component(.day, from: selectedDate!)) + " " + viewController.translateMonth(month: formatter.string(from: selectedDate!)) + " " + String(calendar.component(.year, from: selectedDate!))
                holidayDetails.date = selectedDate
                holidayDetails.body = viewController.GenerateAttributedStringHoliday(holidayString: (viewController.RemoveDateFromHolidayString(holidayString: viewController.RemoveAddInfoHoliday(holidayString: (selectedHoliday?.holiday)!)  , date: selectedDate!)))
                holidayDetails.addInfo = viewController.ExtractAddInfoHoliday(holidayString: (selectedHoliday?.holiday)!)
            }
        }
    }
    
    @IBAction func ExpandCollapseAllButtonClick(_ sender: Any) {
        if !areAllExpanded! {
            areAllExpanded = true
            ExpandCollapseAllButton.title = "Restrange toate"
            
            for i in 0..<sections.count {
                if !sections[i].expanded {
                    toggleSection(header: ExpandableHeaderView(), section: i)
                }
            }
        } else {
            areAllExpanded = false
            ExpandCollapseAllButton.title = "Extinde toate"
            
            for i in 0..<sections.count {
                if sections[i].expanded {
                    toggleSection(header: ExpandableHeaderView(), section: i)
                }
            }
        }
        
    }
    
    func AddNativeExpressAd() {
        var index = 4
        let size = GADAdSizeFromCGSize(CGSize(width: tableView.contentSize.width, height: adViewHeight))
        for i in 0..<sections.count {
            while index < sections[i].holidays.count {
                do {
                    let adView = GADNativeExpressAdView(adSize: size)
                    adView?.adUnitID = "ca-app-pub-3495703042329721/7810018908"
                    adView?.rootViewController = self
                    sections[i].holidays.insert(adView!, at: index)
                    adsToLoad.append(adView!)
                    adView?.delegate = self
                    index += adInterval
                } catch {
                    print(error)
                }
                
            }
            index = 4
        }
    }
    
    func LoadNextAd() {
        if !adsToLoad.isEmpty {
            let adView = adsToLoad.removeFirst()
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            adView.load(request)
        }
    }
    
    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        LoadNextAd()
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

