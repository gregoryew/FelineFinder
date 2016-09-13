//
//  PetFinderFind.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/9/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

class PetFinderFindViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBAction func clearTapped(sender: AnyObject) {
        filterOptions.reset()
        self.tableView.reloadData()
    }
    
    @IBAction func DoneTapped(sender: AnyObject) {
        PetFinderBreeds[self.breed!.BreedName] = nil
        zipCode = zipCodeTextField!.text!
        if validateZipCode(zipCode) == false {
            let alert = UIAlertView()
            alert.title = "Invalid Zip Code"
            alert.message = "Please enter a valid zip code."
            alert.addButtonWithTitle("OK")
            alert.show()
        } else {
            performSegueWithIdentifier("PetFinderList", sender: nil)
        }
    }
    
    var breed: Breed?
    var zipCodeTextField: UITextField?
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
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
        
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clearColor()

    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPetFinderList" {
            (segue.destinationViewController as! PetFinderViewController).breed = breed
        } else if segue.identifier == "chooseFilterOptions" {
            (segue.destinationViewController as! FilterOptionsListTableViewController).filterOpt = opt
        }
    }
    
    func validateZipCode(zipCode: String) -> Bool {
        var validZipCode: Bool = false
        
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let DBPath:NSString = documentsPath.stringByAppendingString("/CatFinder.db") as String
        
        let contactDB = FMDatabase(path: DBPath as String)
        
        if contactDB.open() {
            
            var querySQL: String = ""
            var c: Int32 = 0
            
            querySQL = "SELECT Count(*) c FROM ZipCodes WHERE PostalCode = ?"
      
            let results: FMResultSet? = contactDB.executeQuery(querySQL,
                withArgumentsInArray: [zipCode])
            
            while results?.next() == true {
                c = results!.intForColumn("c")
                if c == 0 {
                    validZipCode = false
                }
                else {
                    validZipCode = true
                }
            }
            contactDB.close()
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
        return validZipCode
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Saves"
        case 1:
            return "Breeds"
        case 2:
            return "Location"
        case 3:
            return "Administrative"
        case 4:
            return "Compatiblity"
        case 5:
            return "Personality"
        case 6:
            return "Physical"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
                return filterOptions.adminList.count
            case 4:
                return filterOptions.compatibilityList.count
            case 5:
                return filterOptions.personalityList.count
            case 6:
                return filterOptions.physicalList.count
            default:
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
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
            opt = filterOptions.adminList[indexPath.row]
            break
        case 4:
            opt = filterOptions.compatibilityList[indexPath.row]
            break
        case 5:
            opt = filterOptions.personalityList[indexPath.row]
            break
        case 6:
            opt = filterOptions.physicalList[indexPath.row]
            break
        default:
            break
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath) as! FilterOptionsListTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.ListName.text = opt!.name
            cell.ListValue.text = opt?.getDisplayValues()
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath) as! FilterOptionsListTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.ListName.text = opt!.name
            cell.ListValue.text = opt?.getDisplayValues()
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("zipCode", forIndexPath: indexPath) as! FilterOptionsZipCodeTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.ZipCodeTextbox.delegate = self
            cell.ZipCodeTextbox.text = zipCode
            zipCodeTextField = cell.ZipCodeTextbox
            return cell
        } else if indexPath.section >= 3 {
            if opt!.list == true {
                let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath) as! FilterOptionsListTableCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.ListName.text = opt!.name
                cell.ListValue.text = opt?.getDisplayValues()
                return cell
            } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("options", forIndexPath: indexPath) as! FilterOptionsSegmentedTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.OptionLabel.text = opt!.name
            cell.OptionSegmentedControl.items = opt!.optionsArray()
            cell.OptionSegmentedControl.font = UIFont(name: "Avenir-Black", size: 12)
            cell.OptionSegmentedControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
            cell.OptionSegmentedControl.selectedIndex = opt!.choosenValue!
            cell.OptionSegmentedControl.tag = indexPath.row
            cell.OptionSegmentedControl.addTarget(self, action: #selector(PetFinderFindViewController.segmentValueChanged(_:)), forControlEvents: .ValueChanged)
            cell.OptionSegmentedControl.tag = opt!.sequence
            return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath)
            return cell
        }
    }
    
    func segmentValueChanged(sender: AnyObject?) {
        filterOptions.filteringOptions[sender!.tag].choosenValue = sender!.selectedIndex
    }
    
    var opt: filterOption?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
                opt = filterOptions.adminList[indexPath.row]
                break
            case 4:
                opt = filterOptions.compatibilityList[indexPath.row]
                break
            case 5:
                opt = filterOptions.personalityList[indexPath.row]
                break
            case 6:
                opt = filterOptions.physicalList[indexPath.row]
                break
            default:
                break
            }
            //opt = filterOptions.filteringOptions[indexPath.row]
            let list = opt!.list
            if list == true {
                performSegueWithIdentifier("chooseFilterOptions", sender: nil)
            }
        }
    }
    
    @IBAction func unwindToPetFinderFind(sender: UIStoryboardSegue)
    {
        let sourceViewController = sender.sourceViewController as! FilterOptionsListTableViewController
        var i = 0
        if sourceViewController.filterOpt?.classification == .saves {
            if sourceViewController.filterOpt?.choosenListValues.count > 0 {
                filterOptions.retrieveSavedFilterValues((sourceViewController.filterOpt?.choosenListValues[0])!, filterOptions: filterOptions, choosenListValues: (sourceViewController.filterOpt?.choosenListValues)!)
            }
        }
        for o in filterOptions.filteringOptions {
            if sourceViewController.filterOpt?.name == o.name {
                filterOptions.filteringOptions[i].choosenListValues = (sourceViewController.filterOpt?.choosenListValues)!
            }
            i += 1
        }
        self.tableView.reloadData()
        // Pull any data from the view controller which initiated the unwind segue.
    }

}