//
//  PetFinderFind.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/9/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class PetFinderFindViewController: UITableViewController, UITextFieldDelegate, NavgationTransitionable, ModalTransitionDelegate {
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    deinit {
        print ("PetFinderFindViewController deinit")
    }
    
    @IBOutlet weak var clear: UIBarButtonItem!
    
    @IBAction func clearTapped(_ sender: AnyObject) {
        filterOptions.reset()
        currentFilterSave = "Touch Here To Load/Save..."
        self.tableView.reloadData()
    }
    
    @IBAction func SaveTapped(_ sender: Any) {
        let opt = filterOptions.filteringOptions[0]
        let listOptions = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOptions") as! FilterOptionsListTableViewController
        listOptions.filterOpt = opt
        listOptions.save = true
        sourceViewController = listOptions
        navigationController?.tr_pushViewController(listOptions, method: DemoTransition.Slide(direction: DIRECTION.left))
    }
    
    @IBAction func DoneTapped(_ sender: AnyObject) {
        PetFinderBreeds[bnGlobal] = nil
        bnGlobal = ""
        zipCodeGlobal = ""
        zipCode = zipCodeTextField!.text!
        if validateZipCode(zipCode) == false {
            Utilities.displayAlert("Invalid Zip Code", errorMessage: "Please enter a valid zip code.")
        } else {
            sourceViewController = nil
            //UserDefaults.standard.set(zipCode, forKey: "zipCode")
            viewPopped = true
            _ = navigationController?.tr_popViewController()
        }
    }
    
    @IBAction func importQuestions(_ sender: Any) {
        let alert = UIAlertController(title: "Import", message: "Do you want to import your current answers, choose a saved answers, new, or cancel?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Current", style: UIAlertActionStyle.default, handler: { action in filterOptions.importQuestions()
            self.tableView.reloadData()}))
        alert.addAction(UIAlertAction(title: "Saved", style: UIAlertActionStyle.default, handler: {action in
            cameFromFiltering = true
            questionList = QuestionList()
            questionList.getQuestions()
            SearchTitle = "SUMMARY"
            self.performSegue(withIdentifier: "importFromSaved", sender: nil)}))
        alert.addAction(UIAlertAction(title: "New", style: UIAlertActionStyle.default, handler: {action in
            cameFromFiltering = true
            questionList = QuestionList()
            questionList.getQuestions()
            SearchTitle = "SUMMARY"
            self.performSegue(withIdentifier: "answerQuestions", sender: nil)}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    var breed: Breed?
    var zipCodeTextField: UITextField?
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        var proceed = true
        if validateZipCode(zipCode) == false {
            proceed = false
        }
        else {
            proceed = true
        }
        return proceed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterOptions.load(self.tableView)
        
        if cameFromFiltering {
            filterOptions.importQuestions()
            self.tableView.reloadData()
            cameFromFiltering = false
        }
        
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = lightBackground

        self.navigationController?.setToolbarHidden(true, animated: false)
        
    }
    
    func addDoneButtonTo(textField: UITextField) {
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(didTapDone))
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    func didTapDone(sender: AnyObject) {
        zipCodeGlobal = (zipCodeTextField?.text!)!
        zipCode = (zipCodeTextField?.text!)!
        zipCodeTextField?.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = lightBackground
    }
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPetFinderList" {
            (segue.destination as! PetFinderViewController).breed = breed
        } else if segue.identifier == "chooseFilterOptions" {
            (segue.destination as! FilterOptionsListTableViewController).filterOpt = opt
        }
    }
    
    func validateZipCode(_ zipCode: String) -> Bool {
        return DatabaseManager.sharedInstance.validateZipCode(zipCode: zipCode)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Saves"
        case 1:
            return "Breeds"
        case 2:
            return "Location"
        case 3:
            return "Filtering Options"
        case 4:
            if filterType == FilterType.Simple {
                return "Simple Options"
            } else {
                return "Administrative"
            }
        case 5:
            return "Compatiblity"
        case 6:
            return "Personality"
        case 7:
            return "Physical"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = headerLightColor
        header.darkColor = headerDarkColor
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if filterType == .Simple {
            return 5
        } else {
            return 8
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            if filterOptions.savesOption != nil {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {  //Breed
            if filterOptions.breedOption != nil {
                return 2
            } else {
                return 0
            }
        } else if section == 2 {
            return 1
        } else {
            switch section {
            case 3:
                return filterOptions.sortByList.count
            case 4:
                if filterType == FilterType.Simple {
                    print("Basic \(filterOptions.basicList.count)")
                    return filterOptions.basicList.count
                } else {
                    print("adminList \(filterOptions.adminList.count)")
                    return filterOptions.adminList.count
                }
            case 5:
                return filterOptions.compatibilityList.count
            case 6:
                return filterOptions.personalityList.count
            case 7:
                return filterOptions.physicalList.count
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var opt: filterOption?
        
        switch indexPath.section {
        case 0:
            opt = filterOptions.savesOption
        case 1:
            if indexPath.row == 0 {
                opt = filterOptions.breedOption
            } else {
                opt = filterOptions.notBreedOption
            }
        case 3:
            opt = filterOptions.sortByList[indexPath.row]
        case 4:
            if filterType == FilterType.Simple {
                opt = filterOptions.basicList[indexPath.row]
            } else {
                opt = filterOptions.adminList[indexPath.row]
            }
        case 5:
            opt = filterOptions.compatibilityList[indexPath.row]
        case 6:
            opt = filterOptions.personalityList[indexPath.row]
        case 7:
            opt = filterOptions.physicalList[indexPath.row]
        default:
            break
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.ListName.text = opt!.name
            cell.ListValue.text = currentFilterSave
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.ListName.text = opt!.name
            cell.ListValue.text = opt?.getDisplayValues()
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zipCode", for: indexPath) as! FilterOptionsZipCodeTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.ZipCodeTextbox.delegate = self
            cell.ZipCodeTextbox.text = zipCode
            zipCodeTextField = cell.ZipCodeTextbox
            addDoneButtonTo(textField: zipCodeTextField!)
            return cell
        } else if indexPath.section >= 3 {
            if opt!.list == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.ListName.text = opt!.name
                cell.ListValue.text = opt?.getDisplayValues()
                if (opt?.imported)! {
                    cell.ListName.textColor = UIColor.red
                } else {
                    cell.ListName.textColor = textColor
                }
                return cell
            } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "options", for: indexPath) as! FilterOptionsSegmentedTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.OptionLabel.text = opt!.name
            cell.OptionSegmentedControl.items = opt!.optionsArray()
            cell.OptionSegmentedControl.font = UIFont(name: "Avenir-Black", size: 12)
            cell.OptionSegmentedControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
            cell.OptionSegmentedControl.selectedIndex = opt!.choosenValue!
            cell.OptionSegmentedControl.tag = indexPath.row
            cell.OptionSegmentedControl.addTarget(self, action: #selector(PetFinderFindViewController.segmentValueChanged(_:)), for: .valueChanged)
            cell.OptionSegmentedControl.tag = opt!.sequence
            if (opt?.imported)! {
                cell.OptionLabel.textColor = UIColor.red
            } else {
                cell.OptionLabel.textColor = textColor
            }
            return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)
            return cell
        }
    }
    
    func segmentValueChanged(_ sender: AnyObject?) {
        filterOptions.filteringOptions[sender!.tag].choosenValue = sender!.selectedIndex
        if (sender!.tag == 4) {
            opt = filterOptions.sortByList[3]
            if opt?.choosenValue == 1 {
                filterType = FilterType.Simple
            } else {
                filterType = FilterType.Advanced
            }
            tableView.reloadData()
        }
    }
    
    var opt: filterOption?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 2 {
            switch indexPath.section {
            case 0:
                opt = filterOptions.savesOption
            case 1:
                if indexPath.row == 0 {
                    opt = filterOptions.breedOption
                } else {
                    opt = filterOptions.notBreedOption
                }
            case 3:
                opt = filterOptions.sortByList[indexPath.row]
            case 4:
                if filterType == .Simple {
                    opt = filterOptions.basicList[indexPath.row]
                } else {
                    opt = filterOptions.adminList[indexPath.row]
                }
                break
            case 5:
                opt = filterOptions.compatibilityList[indexPath.row]
                break
            case 6:
                opt = filterOptions.personalityList[indexPath.row]
                break
            case 7:
                opt = filterOptions.physicalList[indexPath.row]
                break
            default:
                break
            }
            //opt = filterOptions.filteringOptions[indexPath.row]
            let list = opt!.list
            if list == true {
                let listOptions = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOptions") as! FilterOptionsListTableViewController
                listOptions.filterOpt = opt
                sourceViewController = listOptions
                navigationController?.tr_pushViewController(listOptions, method: DemoTransition.Slide(direction: DIRECTION.left))
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if sourceViewController == nil {return}
        
        //let sourceViewController = sender.source as! FilterOptionsListTableViewController
        var i = 0
        if sourceViewController?.filterOpt?.classification == .saves {
            if (sourceViewController?.filterOpt?.choosenValue)! >= 0 {
                filterOptions.retrieveSavedFilterValues((sourceViewController?.filterOpt?.choosenValue)!, filterOptions: filterOptions) //, choosenListValues: (sourceViewController.filterOpt?.choosenListValues)!)
            }
        }
        for o in filterOptions.filteringOptions {
            if sourceViewController?.filterOpt?.name == o.name {
                filterOptions.filteringOptions[i].choosenListValues = (sourceViewController?.filterOpt?.choosenListValues)!
            }
            i += 1
        }
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    @IBAction func unwindToPetFinderFind(_ sender: UIStoryboardSegue)
    {
        let sourceViewController = sender.source as! FilterOptionsListTableViewController
        var i = 0
        if sourceViewController.filterOpt?.classification == .saves {
            if (sourceViewController.filterOpt?.choosenValue)! >= 0 {
                filterOptions.retrieveSavedFilterValues(((sourceViewController.filterOpt?.choosenValue)! + 1), filterOptions: filterOptions) //, choosenListValues: (sourceViewController.filterOpt?.choosenListValues)!)
            }
        }
        for o in filterOptions.filteringOptions {
            if sourceViewController.filterOpt?.name == o.name {
                filterOptions.filteringOptions[i].choosenListValues = (sourceViewController.filterOpt?.choosenListValues)!
            }
            i += 1
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        // Pull any data from the view controller which initiated the unwind segue.
    }

}
