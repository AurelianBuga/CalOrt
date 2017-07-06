//
//  ViewController.swift
//  Test1
//
//  Created by MPBro on 12/05/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData
import UserNotifications
import GoogleMobileAds

class ViewController: UIViewController , GADBannerViewDelegate {
    
    let formatter = DateFormatter()
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var titleView: UINavigationItem!
    @IBOutlet weak var HolidayLabel: UILabel!
    @IBOutlet weak var AddInfoLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var Banner: GADBannerView!
    
    var holidays: [Holiday] = []
    
    let selectedDayColor = UIColor.white
    let currentMonthColor = UIColor.black
    let outsideMonthColor = UIColor(colorWithHexValue: 0xd8d8d8)
    
    var selectedHoliday:HolidayStr?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupCalendarView()
        
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        selectedHoliday = HolidayStr()
        
        //request ad
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        Banner.adUnitID = "ca-app-pub-3495703042329721/6845014697"
        Banner.rootViewController = self
        Banner.load(request)
    }
    
    
    func setSelectedDate(date: Date) {
        self.selectedHoliday?.date = date
    }
    
    func setSelectedHoliday(holiday: String) {
        self.selectedHoliday?.holiday = holiday
    }
    
    func SetupCalendarView() {
        //get rid of border width
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //set title with the corresponding month(translated)
        calendarView.visibleDates { visibleDates in
            self.SetupViewsOfCalendar(from: visibleDates)
        }
        
        //set current date
        setCurrentDate(date: Date())
    }
    
    func handleCellSelected(view: JTAppleCell? , cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        }else {
            validCell.selectedView.isHidden = true
        }
        
    }
    
    func handleCellTextColor(view: JTAppleCell? , cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedDayColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = currentMonthColor
            } else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func translateMonth(month: String) -> String {
        var translatedMonth:String
        
        switch month {
        case "January":
            translatedMonth = "Ianuarie"
            break
        case "February":
            translatedMonth = "Februarie"
            break
        case "March":
            translatedMonth = "Martie"
            break
        case "April":
            translatedMonth = "Aprilie"
            break
        case "May":
            translatedMonth = "Mai"
            break
        case "June":
            translatedMonth = "Iunie"
            break
        case "July":
            translatedMonth = "Iulie"
            break
        case "August":
            translatedMonth = "August"
            break
        case "September":
            translatedMonth = "Septembrie"
            break
        case "October":
            translatedMonth = "Octombrie"
            break
        case "November":
            translatedMonth = "Noiembrie"
            break
        case "December":
            translatedMonth = "Decembrie"
            break
        default:
            translatedMonth = month
            break
        }
        
        return translatedMonth
    }
    
    func setTitle(title: String) {
        self.navigationItem.title = title
    }
    
    func setCurrentDate(date: Date) {
        calendarView.scrollToDate(date)
        calendarView.selectDates([date])
        
        DisplayHoliday(date: date)
        
    }
    
    func DisplayHoliday(date: Date) {
        let dateString = ConvertDateToString(date: date)
        let holidayString = GetHolidayStringByDateString(dateString: dateString!)
        let attributedStringHoliday =  GenerateAttributedStringHoliday(holidayString: RemoveDateFromHolidayString(holidayString: RemoveAddInfoHoliday(holidayString: holidayString), date: date))
        HolidayLabel.attributedText = attributedStringHoliday
        
        setSelectedHoliday(holiday: attributedStringHoliday.string)
        
        let addInfoString = ExtractAddInfoHoliday(holidayString: holidayString)
        
        if addInfoString != "" {
            AddInfoLabel.text = addInfoString
        } else {
            AddInfoLabel.text = ""
        }
    }
    
    func SetupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "MMMM"
        setTitle(title: translateMonth(month: formatter.string(from: date)))
    }
    
    func GetHolidayStringByDateString(dateString: String) -> String {
        var holidayString:String = ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Holidays")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let date = result.value(forKey: "date") as? String
                    {
                        if date == dateString {
                            if let holiday = result.value(forKey: "holiday") as? String
                            {
                                holidayString = holiday
                            }

                        }
                    }
                }
            }
        }catch {
            
        }
        
        return holidayString
    }
    
    func RemoveDateFromHolidayString(holidayString: String , date: Date) -> String {
        var holidayStringWithoutDate = holidayString
        
        let calendar = Calendar.current
        let dayNo = calendar.component(.day, from: date)
        let dayNoRange = holidayStringWithoutDate.range(of: String(dayNo))
        holidayStringWithoutDate.removeSubrange(dayNoRange!)
        
        let treeSpacesRange = holidayStringWithoutDate.range(of: "   ")
        holidayStringWithoutDate.removeSubrange(treeSpacesRange!)
        
        formatter.dateFormat = "EEEE"
        let dayInWeek = TranslateWeekDayName(weekDayName: formatter.string(from: date))
        let index = dayInWeek.index(dayInWeek.startIndex, offsetBy: 1)
        let dayChar = dayInWeek.substring(to: index)
        let dayCharRange = holidayStringWithoutDate.range(of: dayChar)

        holidayStringWithoutDate.removeSubrange(dayCharRange!)
        
        return holidayStringWithoutDate
    }
    
    func ExtractAddInfoHoliday(holidayString: String) -> String {
        //extract additional info : (Harţi) , (Post negru) , (Dezlegare la ulei şi vin) , (Post) , (Dezlegare la ouă, lapte şi brânză) , (Dezlegare la peste) , (Zi aliturgică) (Numai seara, pâine şi apă) ,
        let addInfoList:[String] = ["(Harţi)" , "(Post negru)" , "(Dezlegare la ulei şi vin)" , "(Post)" , "(Dezlegare la ouă, lapte şi brânză)" , "(Dezlegare la peste)" , "(Dezlegare la peşte)" , "(Zi aliturgică)" , "(Numai seara, pâine şi apă)"]
        var addInfoString:String = ""
        
        for addInfo in addInfoList {
            if holidayString.contains(addInfo) {
                var addInfoWithoutBrakets = addInfo
                addInfoWithoutBrakets.remove(at: addInfoWithoutBrakets.startIndex)
                addInfoWithoutBrakets.remove(at: addInfoWithoutBrakets.index(before: addInfoWithoutBrakets.endIndex))
                
                addInfoString += "• " + addInfoWithoutBrakets + "\n"
            }
        }
        
        return addInfoString
    }
    
    func RemoveAddInfoHoliday(holidayString: String) -> String {
        let addInfoList:[String] = ["(Harţi)" , "(Post negru)" , "(Dezlegare la ulei şi vin)" , "(Post)" , "(Dezlegare la ouă, lapte şi brânză)" , "(Dezlegare la peste)" , "(Dezlegare la peşte)" , "(Zi aliturgică)" , "(Numai seara, pâine şi apă)"]
        var outputString:String = ""
        var holidayStringRemovable = holidayString
        
        for addInfo in addInfoList {
            if holidayString.contains(addInfo) {
                outputString = holidayStringRemovable.replacingOccurrences(of: addInfo, with: "")
                holidayStringRemovable = outputString
            }
        }
        
        if outputString != "" {
            return outputString
        } else {
            return holidayString
        }
        
    }
    
    
    func GenerateAttributedStringHoliday(holidayString: String ) -> NSMutableAttributedString {
        //parse custom tags
        var myMutableString = NSMutableAttributedString()
        
        var blueRanges:[Range<String.Index>?] = []
        var redRanges:[Range<String.Index>?] = []
        var boldRanges:[Range<String.Index>?] = []
        
        var holidayStringWithoutBr = holidayString
        
        //replace <br> with '\n'
        if holidayString.range(of: "<br>") != nil {
            let tmpString = holidayString.replacingOccurrences(of: "<br>", with: "\n")
            holidayStringWithoutBr = tmpString
        }
        
        
        
        var holidayStringWithoutTags = ""
        
        var searchStartIndex = holidayStringWithoutBr.startIndex
        
        while searchStartIndex < holidayStringWithoutBr.endIndex {
            let blueStartTag =  holidayStringWithoutBr.range(of:"<a>")
            let redStartTag = holidayStringWithoutBr.range(of:"<r>")
            let blueEndTag =  holidayStringWithoutBr.range(of:"</a>")
            let redEndTag = holidayStringWithoutBr.range(of:"</r>")
            
            if blueStartTag != nil && redStartTag != nil {
                if (blueStartTag?.lowerBound)! < (redStartTag?.lowerBound)! {
                    //add all the text between searchStartIndex and blueStartTag
                    var range = searchStartIndex..<(blueStartTag?.lowerBound)!
                    holidayStringWithoutTags += holidayStringWithoutBr.substring(with: range)
                    
                    //extract blue text
                    range = (blueStartTag?.upperBound)!..<(blueEndTag?.lowerBound)!
                    let blueText = holidayStringWithoutBr.substring(with: range)
                    
                    
                    //add blue text range in blueRanges
                    let blueStartIndex = holidayStringWithoutTags.index(holidayStringWithoutTags.startIndex , offsetBy: holidayStringWithoutTags.characters.count)
                    holidayStringWithoutTags += blueText
                    let blueEndIndex = holidayStringWithoutTags.endIndex
                    
                    range = blueStartIndex..<blueEndIndex
                    
                    blueRanges.append(range)
                    
                    searchStartIndex = (blueEndTag?.upperBound)!
                    
                    let newBlueEndIndex = holidayStringWithoutBr.index((blueEndTag?.upperBound)! , offsetBy: -7)
                    
                    //remove <a> </a> tags
                    holidayStringWithoutBr.removeSubrange(blueEndTag!)
                    holidayStringWithoutBr.removeSubrange(blueStartTag!)
                    
                    //adjust searchStartIndex after adjustments
                    if holidayStringWithoutBr.endIndex > newBlueEndIndex {
                        searchStartIndex = newBlueEndIndex
                    } else {
                        searchStartIndex = holidayStringWithoutBr.endIndex
                    }

                } else
                    if (blueStartTag?.lowerBound)! > (redStartTag?.lowerBound)! {
                        
                        //add all the text between searchStartIndex and redStartTag
                        var range = searchStartIndex..<(redStartTag?.lowerBound)!
                        holidayStringWithoutTags += holidayStringWithoutBr.substring(with: range)
                        
                        //extract red text
                        range = (redStartTag?.upperBound)!..<(redEndTag?.lowerBound)!
                        let redText = holidayStringWithoutBr.substring(with: range)
                        
                        
                        
                        
                        let redStartIndex = holidayStringWithoutTags.index(holidayStringWithoutTags.startIndex , offsetBy: holidayStringWithoutTags.characters.count)
                        holidayStringWithoutTags += redText
                        let redEndIndex = holidayStringWithoutTags.endIndex
                        
                        range = redStartIndex..<redEndIndex
                        //add red text range in redRanges
                        redRanges.append(range)
                        
                        searchStartIndex = (redEndTag?.upperBound)!
                        
                        let newRedEndIndex = holidayStringWithoutBr.index((redEndTag?.upperBound)! , offsetBy: -7)
                        
                        //remove <a> </a> tags
                        holidayStringWithoutBr.removeSubrange(redEndTag!)
                        holidayStringWithoutBr.removeSubrange(redStartTag!)
                        
                        
                        
                        //adjust searchStartIndex after adjustments
                        if holidayStringWithoutBr.endIndex > newRedEndIndex {
                            searchStartIndex = newRedEndIndex
                        } else {
                            searchStartIndex = holidayStringWithoutBr.endIndex
                        }

                }
            } else
                if blueStartTag != nil {
                    //add all the text between searchStartIndex and blueStartTag
                    var range = searchStartIndex..<(blueStartTag?.lowerBound)!
                    holidayStringWithoutTags += holidayStringWithoutBr.substring(with: range)
                    
                    //extract blue text
                    range = (blueStartTag?.upperBound)!..<(blueEndTag?.lowerBound)!
                    let blueText = holidayStringWithoutBr.substring(with: range)
                    
                    
                    
                    //add blue text range in blueRanges
                    let blueStartIndex = holidayStringWithoutTags.index(holidayStringWithoutTags.startIndex , offsetBy: holidayStringWithoutTags.characters.count)
                    holidayStringWithoutTags += blueText
                    let blueEndIndex = holidayStringWithoutTags.endIndex
                    
                    range = blueStartIndex..<blueEndIndex
                    
                    blueRanges.append(range)
                    
                    searchStartIndex = (blueEndTag?.upperBound)!
                    
                    let newBlueEndIndex = holidayStringWithoutBr.index((blueEndTag?.upperBound)! , offsetBy: -7)
                    
                    //remove <a> </a> tags
                    holidayStringWithoutBr.removeSubrange(blueEndTag!)
                    holidayStringWithoutBr.removeSubrange(blueStartTag!)
                    
                    //adjust searchStartIndex after adjustments
                    if holidayStringWithoutBr.endIndex > newBlueEndIndex {
                        searchStartIndex = newBlueEndIndex
                    } else {
                        searchStartIndex = holidayStringWithoutBr.endIndex
                    }
            } else
                if redStartTag != nil {
                    //add all the text between searchStartIndex and redStartTag
                    var range = searchStartIndex..<(redStartTag?.lowerBound)!
                    holidayStringWithoutTags += holidayStringWithoutBr.substring(with: range)
                    
                    //extract red text
                    range = (redStartTag?.upperBound)!..<(redEndTag?.lowerBound)!
                    let redText = holidayStringWithoutBr.substring(with: range)
                    
                    
                    
                    //add red text range in blueRanges
                    let redStartIndex = holidayStringWithoutTags.index(holidayStringWithoutTags.startIndex , offsetBy: holidayStringWithoutTags.characters.count)
                    holidayStringWithoutTags += redText
                    let redEndIndex = holidayStringWithoutTags.endIndex
                    
                    range = redStartIndex..<redEndIndex
                    
                    redRanges.append(range)
                    
                    searchStartIndex = (redEndTag?.upperBound)!
                    
                    let newRedEndIndex = holidayStringWithoutBr.index((redEndTag?.upperBound)! , offsetBy: -7)
                    
                    //remove <a> </a> tags
                    holidayStringWithoutBr.removeSubrange(redEndTag!)
                    holidayStringWithoutBr.removeSubrange(redStartTag!)
                    
                    
                    
                    //adjust searchStartIndex after adjustments
                    if holidayStringWithoutBr.endIndex > newRedEndIndex {
                        searchStartIndex = newRedEndIndex
                    } else {
                        searchStartIndex = holidayStringWithoutBr.endIndex
                    }
                    
            }
                else {
                    holidayStringWithoutTags += holidayStringWithoutBr.substring(from: searchStartIndex)
                    searchStartIndex = holidayStringWithoutBr.endIndex
            }
        }
        
        var boldTagsStillExists:Bool = true
        
        while boldTagsStillExists {
            let boldStartTag =  holidayStringWithoutTags.range(of:"<b>")
            let boldEndTag =  holidayStringWithoutTags.range(of:"</b>")
            
            if boldStartTag == nil || boldEndTag == nil {
                break
            }
            
            //if bold tags are inside <r>...</r>
            if boldStartTag != nil {
                if blueRanges.count != 0 {
                    for var i in 0...(blueRanges.count - 1) {
                        if (blueRanges[i]?.lowerBound)! > (boldEndTag?.upperBound)! {
                            var newLowerBound = holidayStringWithoutTags.index((blueRanges[i]?.lowerBound)! , offsetBy: -7)
                            var newUpperBound = holidayStringWithoutTags.index((blueRanges[i]?.upperBound)! , offsetBy: -7)
                            var newRange = newLowerBound..<newUpperBound
                            blueRanges.remove(at: i)
                            i -= 1
                            blueRanges.append(newRange)
                        }
                    }
                }
                
                var redRangesToRemove:[Int] = []
                var redRangesCount = redRanges.count
                
                if redRanges != nil {
                    for var i in 0...(redRangesCount - 1) {
                        if (redRanges[i]?.lowerBound)! >= (boldEndTag?.upperBound)! {
                            var newLowerBound = holidayStringWithoutTags.index((redRanges[i]?.lowerBound)! , offsetBy: -7)
                            var newUpperBound = holidayStringWithoutTags.index((redRanges[i]?.upperBound)! , offsetBy: -7)
                            var newRange = newLowerBound..<newUpperBound
                            redRanges.remove(at: i)
                            i -= 1
                            redRanges.append(newRange)
                        } else //if bold is inside <r>..</r>
                            if (redRanges[i]?.lowerBound)! <= (boldStartTag?.lowerBound)! && (redRanges[i]?.upperBound)! > (boldEndTag?.upperBound)! {
                                var newLowerBound = (redRanges[i]?.lowerBound)!
                                var newUpperBound = holidayStringWithoutTags.index((redRanges[i]?.upperBound)! , offsetBy: -7)
                                var newRange = newLowerBound..<newUpperBound
                                redRangesToRemove.append(i)
                                redRanges.append(newRange)
                        }
                    }
                    
                    for i in 0...(redRangesToRemove.count - 1) {
                        redRanges.remove(at: redRangesToRemove[i])
                    }
                    
                }
                
                boldRanges.append((boldStartTag?.lowerBound)!..<holidayStringWithoutTags.index((boldEndTag?.lowerBound)! , offsetBy: -3))
                
                holidayStringWithoutTags.removeSubrange(boldEndTag!)
                holidayStringWithoutTags.removeSubrange(boldStartTag!)
            }
            
        }
        
        
        myMutableString = NSMutableAttributedString(string: holidayStringWithoutTags)
        
        for range in blueRanges {
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: holidayStringWithoutTags.nsRange(from: range!))
        }
        
        for range in redRanges {
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: holidayStringWithoutTags.nsRange(from: range!))
        }
        
        for range in boldRanges {
            myMutableString.addAttribute(NSFontAttributeName , value: UIFont.boldSystemFont(ofSize: 14.0)  , range: holidayStringWithoutTags.nsRange(from: range!))
        }

        return myMutableString
    }
    
    func GetWeekDayName(date: Date) -> String {
        formatter.dateFormat = "EEEE"
        let dayInWeek = formatter.string(from: date)
        let translatedDayWeek = TranslateWeekDayName(weekDayName: dayInWeek)
        
        return translatedDayWeek
    }
    
    func TranslateWeekDayName(weekDayName: String) -> String {
        var translatedWeekDay:String = ""
        
        switch weekDayName {
        case "Monday" :
            translatedWeekDay = "Luni"
            break
        case "Tuesday" :
            translatedWeekDay = "Marți"
            break
        case "Wednesday" :
            translatedWeekDay = "Miercuri"
            break
        case "Thursday" :
            translatedWeekDay = "Joi"
            break
        case "Friday" :
            translatedWeekDay = "Vineri"
            break
        case "Saturday" :
            translatedWeekDay = "Sâmbătă"
            break
        case "Sunday" :
            translatedWeekDay = "Duminică"
            break
        default:
            translatedWeekDay = weekDayName.capitalizingFirstLetter()
        }
        
        return translatedWeekDay
    }
    

    
    
    func DisplayDate(date: Date) {
        let weekDayName = GetWeekDayName(date: date)
        let weekDayNameTrans = TranslateWeekDayName(weekDayName: weekDayName)
        let calendar = Calendar.current
        let dayNo = calendar.component(.day, from: date)
        DateLabel.text = String(dayNo) + ", " + weekDayName
    }
    
    func ConvertDateToString(date: Date) -> String? {
        let year = String(Calendar.current.component(.year, from: date))
        let month = String(Calendar.current.component(.month, from: date))
        let day = String(Calendar.current.component(.day, from: date))
        
        return year + " " + month + " " + day
    }
    
    
    @IBAction func GoToCurrentDate(_ sender: Any) {
        setCurrentDate(date: Date())
    }
    
    
    @IBAction func SetNotificationButtonClick(_ sender: Any) {
        var date = (selectedHoliday?.date)!
        SetNotification(date: date)
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" {
            
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
                let currentCountStr = UIApplication.shared.applicationIconBadgeNumber.description
                let currentCount = Int(currentCountStr)
                
                if(currentCount! > 0) {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
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

}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}

extension ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let stDate = formatter.date(from: "2017 01 01")!
        let enDate = formatter.date(from: "2017 12 31")!
        
        let parameters = ConfigurationParameters(startDate: stDate, endDate: enDate, numberOfRows: 6, calendar: nil, generateInDates: nil, generateOutDates: nil, firstDayOfWeek: .monday, hasStrictBoundaries: nil)
        return parameters
    }
}

extension ViewController: JTAppleCalendarViewDelegate {
    //Dislay the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        setSelectedDate(date: date)
        DisplayDate(date: date)
        DisplayHoliday(date: cellState.date)
        
        //scroll to next/prev month if selected date is not from this month
        if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            setCurrentDate(date: date)
        } else
            if cellState.dateBelongsTo == .previousMonthWithinBoundary {
                setCurrentDate(date: date)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        SetupViewsOfCalendar(from: visibleDates)
    }
}



extension UIColor {
    convenience init(colorWithHexValue value: Int , alpha : CGFloat = 1.0) {
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

