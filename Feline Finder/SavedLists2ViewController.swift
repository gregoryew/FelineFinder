//
//  SavedLists2ViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/12/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

var SavedSearches2: SavedSeachesList = SavedSeachesList()
var WhichSavedList: Int = 0
var SearchTitle: String = ""

class SavedLists2ViewController: UITableViewController {
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            DatabaseManager.sharedInstance.deleteSearch(Int(SavedSearches2[indexPath.row].SavedSearchID))
            SavedSearches2.ss.removeValueForKey(SavedSearches2[indexPath.row].SavedSearchID)
            SavedSearches2.ssd.removeAtIndex(indexPath.row)
            SavedSearches2.keys.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SavedSearches2.loaded == false) {
            SavedSearches2.loadSearches(false)
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if SavedSearches2.count == 0 {
            return 0
        } else {
            return 1
        }
    }
    */
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedSearches2.count
    }
    
    func getDateFromString(date: String?) -> NSDate? {
        if let date1 = date {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let date: NSDate? = dateFormatter.dateFromString(date1)
            return date!
        }
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SavedLists2TableCell
        
        cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        cell.backgroundColor = UIColor.clearColor()
        
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        
        cell.accessoryType = .DisclosureIndicator
        
        cell.textLabel!.text = SavedSearches2[indexPath.row].Title
        cell.textLabel!.highlightedTextColor = UIColor.whiteColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.font = UIFont.boldSystemFontOfSize(14.0)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        WhichSavedList = Int(SavedSearches2[indexPath.row].SavedSearchID)
        SearchTitle = SavedSearches2[indexPath.row].Title
        self.performSegueWithIdentifier("ShowList", sender: nil)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = "Saved Searches"
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowList") {
            (segue.destinationViewController as! SavedListsViewController).whichSavedList = WhichSavedList
            print("WhichSavedList=\(WhichSavedList)")
            (segue.destinationViewController as! SavedListsViewController).whichSegue = "ShowList"
        }
    }
    
    @IBAction func unwindToSavedLists2ViewController(sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
}
