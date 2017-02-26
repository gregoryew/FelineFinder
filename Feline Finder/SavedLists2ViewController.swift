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
            if SavedSearches2.count > 0 {
                tableView.deleteRows(at: [indexPath], with:UITableViewRowAnimation.fade)
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if (SavedSearches2.loaded == false) {
            SavedSearches2.loadSearches(false)
        //}
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        self.navigationController?.setToolbarHidden(true, animated:false);
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SavedSearches2.count == 0 {return 1}
        return SavedSearches2.count
    }
    
    func getDateFromString(_ date: String?) -> Date? {
        if let date1 = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
        
        cell.backgroundColor = lightBackground
        
        if SavedSearches2.count == 0 {
            cell.textLabel!.text = "To save a search do one from title screen."
            cell.textLabel!.highlightedTextColor = UIColor.brown
            cell.textLabel!.textColor = textColor
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
            return cell
        }
        
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel!.text = SavedSearches2[indexPath.row].Title
        cell.textLabel!.highlightedTextColor = UIColor.brown
        cell.textLabel!.textColor = textColor
        cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if SavedSearches2.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SavedSearches2.count == 0 {return}
        WhichSavedList = Int(SavedSearches2[indexPath.row].SavedSearchID)
        SearchTitle = SavedSearches2[indexPath.row].Title
        let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedSelections") as! SavedListsViewController
        savedLists.whichSavedList = WhichSavedList
        savedLists.whichSegue = "ShowList"
        navigationController?.tr_pushViewController(savedLists, method: TRPushTransitionMethod.fade, completion: {})
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = headerLightColor
        header.darkColor = headerDarkColor
        header.titleLabel.text = "Saved Searches"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBAction func backTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
    }
}
