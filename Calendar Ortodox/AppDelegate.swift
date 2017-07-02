//
//  AppDelegate.swift
//  Test1
//
//  Created by MPBro on 12/05/2017.
//  Copyright © 2017 MPBro. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        //let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if true {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        
        return true
    }
    
    func parseCSV (contentsOfURL: URL, encoding: String.Encoding, error: NSErrorPointer) -> [[String]]? {
        // Load the CSV file and parse it
        let delimiter = ","
        
        var endcodingVar = encoding
        var values:[[String]] = [[]]
        do{
            let content = try String(contentsOf: contentsOfURL, usedEncoding: &endcodingVar)
            var lines:[String] = []
            content.enumerateLines { line, _ in
                lines.append(line)
            }
            var i = 0
            for line in lines {
                if line != "" {
                    values.append([])
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        var value:String?
                        //var textScanner:Scanner = Scanner(string: textToScan)
                        var addedText = false
                        
                        
                        while textToScan != "" {
                            
                            if textToScan.range(of: "\"")?.lowerBound == textToScan.startIndex {
                                var endRange:Range<String.Index>?
                                var startRange:Range<String.Index>?
                                
                                if textToScan.range(of: "\",\"") != nil {
                                    endRange = textToScan.range(of: "\",\"")
                                    startRange = textToScan.range(of: "\"")
                                        value = textToScan.substring(with: (startRange?.upperBound)!..<(endRange?.lowerBound)!)
                                        values[i].append(value as! String)
                                        addedText = true
                                        
                                        textToScan.removeSubrange((startRange?.lowerBound)!..<( textToScan.index((endRange?.upperBound)!, offsetBy: -1)))
                                } else {
                                    endRange =  textToScan.range(of: "\"", options: String.CompareOptions.backwards, range: nil, locale: nil)
                                    startRange = textToScan.range(of: "\"")
                                        value = textToScan.substring(with: (startRange?.upperBound)!..<(endRange?.lowerBound)!)
                                        values[i].append(value as! String)
                                        addedText = true
                                        
                                        textToScan.removeSubrange((startRange?.lowerBound)!..<(endRange?.upperBound)!)
                                }
                                
                                
                            } else {
                                var delimiterRange = textToScan.range(of: ",")
                                value = textToScan.substring(with: textToScan.startIndex..<(delimiterRange?.lowerBound)!)
                                values[i].append(value as! String)
                                addedText = true
                                
                                textToScan.removeSubrange((textToScan.startIndex...(delimiterRange?.lowerBound)!))
                            }
                            
                            // Retrieve the unscanned remainder of the string
                            /*var length = textScanner.string.characters.count
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)*/
                        }
                        
                        if addedText == false {
                            values.remove(at: i)
                            i -= 1
                        }
                        
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values[i] = line.components(separatedBy: delimiter)
                    }
                    
                    i += 1
                    
                    // Put the values into the tuple and add it to the items array
                    //let Holiday = (date: values[0], holiday: values[1])
                    //holidays?.append(Holiday)
                }
            }
            
        } catch {
            
        }
        
        
        return values
    }
    
    func removeElements (entityName: String) {
        do{
            // Remove the existing items
            let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            if managedObjectContext != nil {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.returnsObjectsAsFaults = false
                var e: NSError?
                let elements  = try managedObjectContext.fetch(request)
                
                if e != nil {
                    //println("Failed to retrieve record: \(e!.localizedDescription)")
                    
                } else {
                    
                    for element in elements as! [NSManagedObject] {
                        managedObjectContext.delete(element )
                    }
                }
            }
        }catch{
            
        }
        
    }
    
    func ConvertValuesToHolidays(values: [[String]]) -> [(date:String, holiday:String)]? {
        var holidays:[(date:String, holiday:String)]?
        holidays = []
        for value in values {
            if value.count != 0 {
                let Holiday = (date: value[0], holiday: value[1])
                holidays?.append(Holiday)
            }
            
        }
        
        return holidays
    }
    
    func ConvertValuesToPrayers(values: [[String]]) -> [(name:String , body:String)]? {
        var prayers:[(name:String , body:String)]?
        prayers = []
        for value in values {
            if value.count != 0 {
                let Prayer = (name: value[0] , body: value[1])
                prayers?.append(Prayer)
            }
        }
        
        return prayers
    }
    
    func preloadData() {
        preloadHolidays()
        preloadPrayers()
    }
    
    func preloadHolidays () {
        // Retrieve data from the source file
        do{
            if let contentsOfURL = Bundle.main.url(forResource: "holidays", withExtension: "csv") {
                
                // Remove all the menu items before preloading
                removeElements(entityName: "Holidays")
                
                var error:NSError?
                if let values = parseCSV(contentsOfURL: contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                    if let items = ConvertValuesToHolidays(values: values) {
                        // Preload the menu items
                        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        if managedObjectContext != nil {
                            for item in items {
                                let holiday = NSEntityDescription.insertNewObject(forEntityName: "Holidays", into: managedObjectContext)
                                
                                // 3
                                holiday.setValue(item.date, forKeyPath: "date")
                                holiday.setValue(item.holiday, forKeyPath: "holiday")
                                
                                // 4
                                do {
                                    try managedObjectContext.save()
                                    //holiday.append(holiday)
                                    print("Saved")
                                } catch let error as NSError {
                                    print("Could not save. \(error), \(error.userInfo)")
                                }
                            }
                        }
                    }
                }
            }
            
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func preloadPrayers() {
        // Retrieve data from the source file
        do{
            if let contentsOfURL = Bundle.main.url(forResource: "prayers", withExtension: "csv") {
                
                // Remove all the menu items before preloading
                removeElements(entityName: "Prayers")
                
                var error:NSError?
                if let values = parseCSV(contentsOfURL: contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                    if let items = ConvertValuesToPrayers(values: values) {
                        // Preload the menu items
                        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        if managedObjectContext != nil {
                            for item in items {
                                let prayer = NSEntityDescription.insertNewObject(forEntityName: "Prayers", into: managedObjectContext)
                                
                                // 3
                                prayer.setValue(item.name, forKeyPath: "name")
                                prayer.setValue(item.body, forKeyPath: "body")
                                
                                // 4
                                do {
                                    try managedObjectContext.save()
                                    //holiday.append(holiday)
                                    print("Saved")
                                } catch let error as NSError {
                                    print("Could not save. \(error), \(error.userInfo)")
                                }
                            }
                        }
                    }
                }
            }
            
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Calendar_Ortodox")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

