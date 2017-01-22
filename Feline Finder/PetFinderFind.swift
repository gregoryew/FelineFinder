//
//  PetFinderFind.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/9/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
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


class PetFinderFindViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var clear: UIBarButtonItem!
    @IBOutlet weak var importQuestions: UIBarButtonItem!
    
    @IBAction func clearTapped(_ sender: AnyObject) {
        filterOptions.reset()
        self.tableView.reloadData()
    }
    
    @IBAction func DoneTapped(_ sender: AnyObject) {
        PetFinderBreeds[bnGlobal] = nil
        bnGlobal = ""
        zipCodeGlobal = ""
        zipCode = zipCodeTextField!.text!
        if validateZipCode(zipCode) == false {
            Utilities.displayAlert("Invalid Zip Code", errorMessage: "Please enter a valid zip code.")
        } else {
            UserDefaults.standard.set(zipCode, forKey: "zipCode")
            performSegue(withIdentifier: "PetFinderList", sender: nil)
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
        self.tableView.backgroundColor = UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0)

        self.navigationController?.setToolbarHidden(true, animated: false)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
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
        var validZipCode: Bool = false
        
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let DBPath:NSString = documentsPath.appending("/CatFinder.db") as NSString
        
        let contactDB = FMDatabase(path: DBPath as String)
        
        if (contactDB?.open())! {
            
            var querySQL: String = ""
            var c: Int32 = 0
            
            querySQL = "SELECT Count(*) c FROM ZipCodes WHERE PostalCode = ?"
      
            let results: FMResultSet? = contactDB?.executeQuery(querySQL,
                withArgumentsIn: [zipCode])
            
            while results?.next() == true {
                c = results!.int(forColumn: "c")
                if c == 0 {
                    validZipCode = false
                }
                else {
                    validZipCode = true
                }
            }
            contactDB?.close()
        } else {
            print("Error: \(contactDB?.lastErrorMessage())")
        }
        return validZipCode
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
            return "Sort By"
        case 4:
            return "Administrative"
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
        header.lightColor = UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0)
        header.darkColor = UIColor(red:0.157, green:0.082, blue:0.349, alpha:1.0)
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
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
                return filterOptions.adminList.count
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
            opt = filterOptions.adminList[indexPath.row]
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
            return cell
        } else if indexPath.section >= 3 {
            if opt!.list == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.ListName.text = opt!.name
                cell.ListValue.text = opt?.getDisplayValues()
                if (opt?.imported)! {
                    cell.ListName.textColor = UIColor.green
                } else {
                    cell.ListName.textColor = UIColor(red:0.996, green:0.980, blue:0.341, alpha:1.0)
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
                cell.OptionLabel.textColor = UIColor.green
            } else {
                cell.OptionLabel.textColor = UIColor(red:0.996, green:0.980, blue:0.341, alpha:1.0)
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
                opt = filterOptions.adminList[indexPath.row]
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
                performSegue(withIdentifier: "chooseFilterOptions", sender: nil)
            }
        }
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
