//
//  SavedLists2ViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/12/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation

var SavedSearches2: SavedSeachesList = SavedSeachesList()
var WhichSavedList: Int = 0
var SearchTitle: String = ""

class SavedLists2ViewController: UITableViewController, NavgationTransitionable {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            DatabaseManager.sharedInstance.deleteSearch(Int(SavedSearches2[indexPath.row].SavedSearchID))
            SavedSearches2.ss.removeValue(forKey: SavedSearches2[indexPath.row].SavedSearchID)
            SavedSearches2.ssd.remove(at: indexPath.row)
            SavedSearches2.keys.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with:UITableViewRowAnimation.fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SavedSearches2.loaded == false) {
            SavedSearches2.loadSearches(false)
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedSearches2.count
    }
    
    func getDateFromString(_ date: String?) -> Date? {
        if let date1 = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let date: Date? = dateFormatter.date(from: date1)
            return date!
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SavedLists2TableCell
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        
        cell.backgroundColor = UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0)
        
        /*
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        */
        
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel!.text = SavedSearches2[indexPath.row].Title
        cell.textLabel!.highlightedTextColor = UIColor(red:0.996, green:0.980, blue:0.341, alpha:1.0)
        cell.textLabel!.textColor = UIColor(red:0.996, green:0.980, blue:0.341, alpha:1.0)
        cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        WhichSavedList = Int(SavedSearches2[indexPath.row].SavedSearchID)
        SearchTitle = SavedSearches2[indexPath.row].Title
        let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Selections") as! SavedListsViewController
        savedLists.whichSavedList = WhichSavedList
        savedLists.whichSegue = "ShowList"
        //savedLists.viewDidLoad()
        //savedLists.tableView.reloadData()
        navigationController?.tr_pushViewController(savedLists, method: TRPushTransitionMethod.fade, completion: {})
        //self.performSegue(withIdentifier: "ShowList", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0)
        header.darkColor = UIColor(red:0.157, green:0.082, blue:0.349, alpha:1.0)
        header.titleLabel.text = "Saved Searches"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowList") {
            (segue.destination as! SavedListsViewController).whichSavedList = WhichSavedList
            print("WhichSavedList=\(WhichSavedList)")
            (segue.destination as! SavedListsViewController).whichSegue = "ShowList"
        }
    }
    
    @IBAction func unwindToSavedLists2ViewController(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBAction func backTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
    }
}
