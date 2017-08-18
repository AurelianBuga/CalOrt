//
//  HolidayDetailsViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 23/07/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMobileAds

class HolidayDetailsViewController: UIViewController , PopupDelegate , GADInterstitialDelegate {


    @IBOutlet weak var DayLabel: UILabel!
    @IBOutlet weak var BodyLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var AddInfoLabel: UILabel!
    
    var day: String!
    var dateString:String!
    var body: NSAttributedString!
    var addInfo: String!
    var date:Date!
    
    var selectedCustomDate: Date?
    var formatter:DateFormatter!
    
    var interstitialAd:GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DayLabel.text = day
        DateLabel.text = dateString
        BodyLabel.attributedText = body
        AddInfoLabel.text = addInfo
        
        formatter = DateFormatter()
        
        interstitialAd = CreateAndLoadInterstitialAd()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetDateForNotification(date: Date) {
        selectedCustomDate = date
        SetNotification(self)
    }
    
    @IBAction func SetNotification(_ sender: Any) {
        var date = selectedCustomDate
        if date! < Date() {
            self.createAlert(title: "Alertă" , message: "Nu se poate seta o notificare pentru ziua selectată deoarece această zi a trecut.")
        } else {
            SetNotification(date: date!)
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
                    self.scheduleNotification(at: date)
                    self.randomPresentationOfInterstitialAd(oneIn: 2)
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleNotification(at: date)
                self.randomPresentationOfInterstitialAd(oneIn: 2)
            case .denied:
                self.createAlert(title: "Alertă" , message: "Pentru a putea activa această funcționalitate ar trebui sa permiți aplicației Calendar Ortodox să trimită notificări. Pentru a face asta te rog du-te pe dispozitivul tău in Setări -> Calendar Ortodox -> Notificări și selectează ON la opțiunea Permite notificări.")
            }
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
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Notificare"
        content.body = body.string
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        content.sound = UNNotificationSound.default()
        
        formatter.dateFormat = "yyyy MM dd"
        
        let request = UNNotificationRequest(identifier: "holiday_" + formatter.string(from: date), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var modalDatePicker = segue.destination as! ModalDatePicker
        modalDatePicker.delegate = self
        modalDatePicker.date = date
    }
    
    
}
