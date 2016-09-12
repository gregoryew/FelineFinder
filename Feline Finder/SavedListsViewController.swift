//
//  SavedListsViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/11/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class SavedListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var GoBackButton: UIButton!
    
    @IBAction func goBackTapped(sender: AnyObject) {
        if whichSegue == "ShowList" {
            performSegueWithIdentifier("SavedLists2", sender: nil)
        } else {
            performSegueWithIdentifier("MainMenu", sender: nil)
        }
    }
    
    var whichSegue: String = ""
    var whichQuestion: Int = 0
    var whichSavedList: Int = 0
    var txtfld: UITextField = UITextField()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:false);
        whichSegueGlobal = ""
        if (whichSegue == "Summary") {
            SearchTitle = "Summary"
            SavedSearches.loadSearches(true)
        }
        else if (whichSegue == "SavedSearches") {
            if (SavedSearches.loaded == false) {
                SavedSearches.loadSearches(false)
            }
            questionList.readAnswers(whichSavedList)
            questionList.setAnswers()
        }
        else if (whichSegue == "ShowList") {
            SavedSearches.refresh()
            questionList = QuestionList()
            questionList.getQuestions()
            questionList.readAnswers(whichSavedList)
            SavedSearches.loadSearches(true)
            questionList.setAnswers()

            tableView.reloadData()
       }
        tableView.setContentOffset(CGPointZero, animated:true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
    }
    
    @IBAction func ResultsTouchUpInside(sender: AnyObject) {
        self.performSegueWithIdentifier("results", sender: nil)
    }
    
    //hold this reference in your class
    weak var AddAlertSaveAction: UIAlertAction?
    
    @IBAction func SaveQueryTouchUpInside(sender: AnyObject) {
        //Create the AlertController
            
            let alertController = UIAlertController(title: "Search Name", message: "Please enter the name of the search", preferredStyle: .Alert)
            
            // Add the text field with handler
            alertController.addTextFieldWithConfigurationHandler { textField in
                //listen for changes
                
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SavedListsViewController.handleTextFieldTextDidChangeNotification(_:)), name: UITextFieldTextDidChangeNotification, object: textField)
                
            textField.text = SearchTitle
            self.txtfld = textField
                
            // Create the actions.
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
                NSLog("Cancel Button Pressed");
                 self.removeTextFieldObserver()
            }
            
            let otherAction = UIAlertAction(title: "Save", style: .Default) { action in
                NSLog("Save Button Pressed");
                let ss = SavedSearches[0]
                let ans: Bool = (self.whichSegue == "Summary" ? true : false)
                let n = self.txtfld.text
                SavedSearches.saveSearches(ans, ID: Int(ss.SavedSearchID), SearchName: n!)
                SavedSearches.refresh()
                SavedSearches.loadSearches(false)
                SavedSearches2.refresh()
                SavedSearches2.loadSearches(false)
                self.removeTextFieldObserver()
                SearchTitle = n!
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
                //self.tableView.reloadData()
            }
        
            // disable the 'save' button (otherAction) initially
            if SearchTitle.characters.count == 0 {
                otherAction.enabled = false
            } else {
                otherAction.enabled = true
            }
            
            // save the other action to toggle the enabled/disabled state when the text changed.
            self.AddAlertSaveAction = otherAction
            
            // Add the actions.
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func removeTextFieldObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: self.txtfld)
    }
    
    //handler
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.enabled = textField.text?.characters.count >= 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedSearches[section].SavedSearchDetails.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return SearchTitle
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SavedListsTableCell
        
        cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.textLabel!.highlightedTextColor = UIColor.whiteColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.font = UIFont.boldSystemFontOfSize(14.0)
        
        if SavedSearches[indexPath.section].SavedSearchDetails.count == 0 {
            cell.textLabel!.text = "None saved yet.  Save some questions."
            cell.accessoryView!.hidden = true
            return cell
        }
        
        //cell.accessoryView!.hidden = false
        cell.accessoryType = .DisclosureIndicator
        cell.lastCell = indexPath.row == SavedSearches[indexPath.section].SavedSearchDetails.count - 1
        
        let ss = SavedSearches[indexPath.section].SavedSearchDetails[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        cell.textLabel!.text = "\(ss.Question): \(ss.Choice)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        whichQuestion = indexPath.row
        self.performSegueWithIdentifier("Edit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "results" {
            (segue.destinationViewController as! MasterViewController).whichSeque = "results"
        }
        else if segue.identifier == "Edit" {
            whichSegueGlobal = "Edit"
            editWhichQuestionGlobal = whichQuestion
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    @IBAction func unwindToChoicesViewController(sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        //GoBackButton.frame = CGRectMake(-4.0, 560.0, 328.0, 38.0)
        //print(GoBackButton.frame)
    }
}
