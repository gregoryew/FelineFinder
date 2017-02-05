//
//  FilterOptionsListTableViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/9/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class FilterOptionsListTableViewController: UITableViewController, NavgationTransitionable {
    
    var txtfld: UITextField = UITextField()
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBOutlet weak var SavedButton: UIBarButtonItem!
    
    func removeTextFieldObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: self.txtfld)
    }
    
    //hold this reference in your class
    weak var AddAlertSaveAction: UIAlertAction?
    
    //handler
    func handleTextFieldTextDidChangeNotification(_ notification: Notification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.isEnabled = textField.text?.characters.count >= 1
    }
    
    @IBAction func SavedTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Search Name", message: "Please enter the name of the search", preferredStyle: .alert)
        
        // Add the text field with handler
        alertController.addTextField { textField in
            //listen for changes
            
            NotificationCenter.default.addObserver(self, selector: #selector(SavedListsViewController.handleTextFieldTextDidChangeNotification(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            
            textField.text = SearchTitle
            self.txtfld = textField
            
            // Create the actions.
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                NSLog("Cancel Button Pressed");
                self.removeTextFieldObserver()
            }
            
            let otherAction = UIAlertAction(title: "Save", style: .default) { action in
                NSLog("Save Button Pressed");
                let n = self.txtfld.text
                currentFilterSave = n!
                self.removeTextFieldObserver()
                filterOptions.storeFilters(0, saveName: n!)
                let c = filterOptions.filteringOptions[0].options.count + 1
                filterOptions.filteringOptions[0].options.append((displayName: n!, search: String(NameID), value: c))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            // disable the 'save' button (otherAction) initially
            if SearchTitle.characters.count == 0 {
                otherAction.isEnabled = false
            } else {
                otherAction.isEnabled = true
            }
            
            // save the other action to toggle the enabled/disabled state when the text changed.
            self.AddAlertSaveAction = otherAction
            
            // Add the actions.
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    var filterOpt: filterOption?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        if filterOpt?.classification == .saves {
            SavedButton.title = "Save"
            SavedButton.isEnabled = true
        } else {
            SavedButton.title = ""
            SavedButton.isEnabled = false
        }
    }
    
    @IBAction func unwindToFilterOptionList(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool
    {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filterOpt!.options.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return (filterOpt?.name)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = filterOpt?.optionsArray()[indexPath.row]
        cell.textLabel!.textColor = textColor
        if filterOpt?.classification == .saves {return cell}
        if ((filterOpt?.choosenListValues.contains(indexPath.row)) == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if filterOpt?.classification == .saves {
            filterOpt?.choosenValue = indexPath.row
            let cell = tableView.cellForRow(at: indexPath)
            currentFilterSave = (cell?.textLabel?.text)!
            //filterOpt?.choosenListValues.append(indexPath.row)
            performSegue(withIdentifier: "backToFilterOptions", sender: nil)
        } else if ((filterOpt?.choosenListValues.contains(indexPath.row)) == true) {
            filterOpt?.choosenListValues = (filterOpt?.choosenListValues.filter(){$0 != indexPath.row})!
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            filterOpt?.choosenListValues.append(indexPath.row)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = headerLightColor
        header.darkColor = headerDarkColor
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}
