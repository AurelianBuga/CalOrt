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

class PrayersTableViewController: UITableViewController , GADBannerViewDelegate {
    
    var prayers: [PrayerStr]!
    var selectedPrayer: PrayerStr!
    
    @IBOutlet weak var Banner: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prayers = []
        GetPrayers()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //request ad
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        Banner.adUnitID = "ca-app-pub-3495703042329721/6845014697"
        Banner.rootViewController = self
        Banner.load(request)
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
                        prayers.append(PrayerStr(title: name, body: processPrayer(prayer: body)!))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrayerCell", for: indexPath)

        cell.textLabel?.text = prayers[indexPath.row].title
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        return cell
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
