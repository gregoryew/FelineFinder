//
//  SavedListsViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/11/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
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

class SavedListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NavgationTransitionable {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var GoBackButton: UIButton!
    
    @IBAction func goBackTapped(_ sender: AnyObject) {
        
        _ = navigationController?.tr_popViewController()
        
        //navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
        /*
        if whichSegue == "ShowList" {
            performSegue(withIdentifier: "SavedLists2", sender: nil)
        } else {
            performSegue(withIdentifier: "MainMenu", sender: nil)
        }
        */
    }
    
    var whichSegue: String = ""
    var whichQuestion: Int = 0
    var whichSavedList: Int = 0
    var txtfld: UITextField = UITextField()
    var chosenBreed: Breed?
    
    override func viewWillAppear(_ animated: Bool) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.view.updateConstraintsIfNeeded()
        //tableView.reloadData()
        //tableView.setContentOffset(CGPoint.zero, animated:true)
        print(tableView.frame)
        if tableView.frame.origin.y == 20 {
            tableView.frame = tableView.frame.offsetBy(dx: 0, dy: 45)
        }
        GoBackButton.twinkle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
    }
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBAction func ResultsTouchUpInside(_ sender: AnyObject) {
        if cameFromFiltering {
            self.performSegue(withIdentifier: "filtering", sender: nil)
        } else {
            cameFromFiltering = false
            let masterList = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedList") as! MasterViewController
            if let b = chosenBreed {
                masterList.breed = b
            }
            masterList.whichSeque = "results"
            navigationController?.tr_pushViewController(masterList, method: TRPushTransitionMethod.fade, completion: {})
        }
    }
    
    //hold this reference in your class
    weak var AddAlertSaveAction: UIAlertAction?
    
    @IBAction func SaveQueryTouchUpInside(_ sender: AnyObject) {
        //Create the AlertController
            
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //self.tableView.reloadData()
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
    
    func removeTextFieldObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: self.txtfld)
    }
    
    //handler
    func handleTextFieldTextDidChangeNotification(_ notification: Notification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.isEnabled = textField.text?.characters.count >= 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedSearches[section].SavedSearchDetails.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return SearchTitle
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SavedListsTableCell
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        /*
        cell.backgroundColor = UIColor.darkGray
        */
        cell.backgroundColor = lightBackground
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
        
        /*
        cell.textLabel!.backgroundColor = UIColor.clear
        cell.textLabel!.highlightedTextColor = UIColor.white
        cell.textLabel!.textColor = UIColor.white
        */
        cell.textLabel!.backgroundColor = UIColor.clear
        cell.textLabel!.highlightedTextColor = darkTextColor
        cell.textLabel!.textColor = textColor

        cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        if SavedSearches[indexPath.section].SavedSearchDetails.count == 0 {
            cell.textLabel!.text = "None saved yet.  Save some questions."
            cell.accessoryView!.isHidden = true
            return cell
        }
        
        //cell.accessoryView!.hidden = false
        cell.accessoryType = .disclosureIndicator
        cell.lastCell = indexPath.row == SavedSearches[indexPath.section].SavedSearchDetails.count - 1
        
        let ss = SavedSearches[indexPath.section].SavedSearchDetails[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        
        cell.textLabel!.text = "\(ss.Question): \(ss.Choice)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        whichQuestion = indexPath.row
        self.performSegue(withIdentifier: "Edit", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit" {
            whichSegueGlobal = "Edit"
            editWhichQuestionGlobal = whichQuestion
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        /*
        header.lightColor = UIColor(red:0.51, green:0.73, blue:0.84, alpha:1.0)
        header.darkColor = UIColor(red:0.51, green:0.73, blue:0.84, alpha:1.0)
        */
        header.lightColor = lightBackground
        header.darkColor = darkBackground
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBAction func backTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
    }
    
    @IBAction func unwindToChoicesViewController(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        //GoBackButton.frame = CGRectMake(-4.0, 560.0, 328.0, 38.0)
        //print(GoBackButton.frame)
    }
}
