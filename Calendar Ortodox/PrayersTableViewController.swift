//
//  PrayersTableViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 01/07/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

struct PrayerStr {
    var title: String!
    var body: String!
    
    init(title: String , body:String) {
        self.title = title
        self.body = body
    }
}

class PrayersTableViewController: UITableViewController , GADNativeExpressAdViewDelegate  {
    
    var prayers: [AnyObject]!
    var selectedPrayer: PrayerStr!
    var adsToLoad = [GADNativeExpressAdView]()
    let adInterval = 5
    let adViewHeight = CGFloat(80)

    override func viewDidLoad() {
        super.viewDidLoad()
        prayers = []
        GetPrayers()

        tableView.register(UINib(nibName: "NativeAdExpress" , bundle: nil), forCellReuseIdentifier: "NativeAdExpressCellView")
        
        AddNativeExpressAd()
        LoadNextAd()
        //reset badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return prayers.count
    }
    
    func GetPrayers() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Prayers")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String , let body = result.value(forKey: "body") as? String {
                        prayers.append(PrayerStr(title: name, body: processPrayer(prayer: body)!) as AnyObject)
                    }
                }
            }
        }catch {
            
        }
    }
    
    func processPrayer(prayer: String) -> String? {
        var result: String?
        result = prayer
        
        //parse <i> : indent
        if prayer.range(of: "<i>") != nil {
            let tmpString = result?.replacingOccurrences(of: "<i>", with: "\t")
            result = tmpString
        }
        
        //parse <br> : new line
        if prayer.range(of: "<br>") != nil {
            let tmpString = result?.replacingOccurrences(of: "<br>", with: "\n")
            result = tmpString
        }
        
        return result
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let prayer = prayers[indexPath.row] as? PrayerStr {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrayerCell", for: indexPath)
            
            cell.textLabel?.text = prayer.title
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
            return cell
            
        } else {
            let adView = prayers[indexPath.row] as! GADNativeExpressAdView
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
        if let prayer = prayers[indexPath.row] as? PrayerStr {
            selectedPrayer = prayer as! PrayerStr
            performSegue(withIdentifier: "prayerSegue", sender: self)
        }
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if selectedPrayer != nil {
            var prayerViewController = segue.destination as! PrayerViewController
            prayerViewController.name = selectedPrayer.title
            prayerViewController.body = selectedPrayer.body
        }
    }

    func AddNativeExpressAd() {
        var index = 4
        let size = GADAdSizeFromCGSize(CGSize(width: tableView.contentSize.width, height: adViewHeight))
        while index < prayers.count {
            let adView = GADNativeExpressAdView(adSize: size)
            adView?.adUnitID = "ca-app-pub-3495703042329721/7810018908"
            adView?.rootViewController = self
            prayers.insert(adView!, at: index)
            adsToLoad.append(adView!)
            adView?.delegate = self
            index += adInterval
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if prayers[indexPath.row] is GADNativeExpressAdView {
            return CGFloat(adViewHeight)
        } else {
            return CGFloat(50)
        }
    }
}


