//
//  UsefulInfoTableViewController.swift
//  Calendar Ortodox
//
//  Created by MPBro on 02/07/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import CoreData

struct UsefulInfoStr {
    var category:String!
    var text:String!
    
    init(category:String , text:String) {
        self.category = category
        self.text = text
    }
}

class UsefulInfoTableViewController: UITableViewController {
    
    var usefulInfos: [UsefulInfoStr]!
    var categories: [String]!

    override func viewDidLoad() {
        usefulInfos = []
        SetUsefulInfos()
        SetCategories()
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    
    func SetUsefulInfos() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UsefulInfos")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    
                    if let category = result.value(forKey: "category") as? String , let text = result.value(forKey: "text") as? String {
                        usefulInfos.append(UsefulInfoStr(category: category, text: text))
                    }
                }
            }
        }catch {
            
        }
    }
    
    func SetCategories() {
        var categories: [String] = []
        for usefulInfo in usefulInfos {
            if !categories.contains(usefulInfo.category) {
                categories.append(usefulInfo.category)
            }
        }
        
        self.categories = categories
    }
    
    func GetTextsForCategory(categoryIndex:Int) -> [String]? {
        var texts:[String]? = []
        let category = categories[categoryIndex]
        for usefulInfo in usefulInfos {
            if usefulInfo.category == category {
                texts?.append(usefulInfo.text)
            }
        }
        
        return texts
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GetTextsForCategory(categoryIndex: section)!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var viewController: ViewController = ViewController()
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsefulInfoCell", for: indexPath)

        cell.textLabel?.attributedText = viewController.GenerateAttributedStringHoliday(holidayString: (GetTextsForCategory(categoryIndex: indexPath.section)?[indexPath.row])!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UsefulInfoHeaderView()
        headerView.customInit(title: categories[section], section: section)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}

extension String {
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
    
}
