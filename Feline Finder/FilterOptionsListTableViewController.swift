//
//  FilterOptionsListTableViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/9/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class FilterOptionsListTableViewController: UITableViewController {
    
    var txtfld: UITextField = UITextField()
    
    @IBOutlet weak var SavedButton: UIBarButtonItem!
    
    func removeTextFieldObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: self.txtfld)
    }
    
    //hold this reference in your class
    weak var AddAlertSaveAction: UIAlertAction?
    
    //handler
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.enabled = textField.text?.characters.count >= 1
    }
    
    @IBAction func SavedTapped(sender: AnyObject) {
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
                let n = self.txtfld.text
                self.removeTextFieldObserver()
                filterOptions.storeFilters(0, saveName: n!)
                let c = filterOptions.filteringOptions[0].options.count + 1
                filterOptions.filteringOptions[0].options.append((displayName: n!, search: String(NameID), value: c))
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
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
    
    var filterOpt: filterOption?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        if filterOpt?.classification == .saves {
            SavedButton.title = "Save"
            SavedButton.enabled = true
        } else {
            SavedButton.title = ""
            SavedButton.enabled = false
        }
    }
    
    @IBAction func unwindToFilterOptionList(sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filterOpt!.options.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return (filterOpt?.name)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = filterOpt?.optionsArray()[indexPath.row]
        if filterOpt?.classification == .saves {return cell}
        if ((filterOpt?.choosenListValues.contains(indexPath.row)) == true) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if filterOpt?.classification == .saves {
            filterOpt?.choosenListValues = []
            filterOpt?.choosenListValues.append(indexPath.row)
            performSegueWithIdentifier("backToFilterOptions", sender: nil)
        } else if ((filterOpt?.choosenListValues.contains(indexPath.row)) == true) {
            filterOpt?.choosenListValues = (filterOpt?.choosenListValues.filter(){$0 != indexPath.row})!
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        } else {
            filterOpt?.choosenListValues.append(indexPath.row)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}