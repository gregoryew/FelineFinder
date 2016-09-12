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
        }
    performSegueWithIdentifier("PetFinderList", sender: nil)
    }
    
    
    var breed: Breed?
    var zipCodeTextField: UITextField?
    
    @IBAction func FindTouchUp(sender: AnyObject) {
        zipCode = zipCodeTextField!.text!
        if validateZipCode(zipCode) == false {
            let alert = UIAlertView()
            alert.title = "Invalid Zip Code"
            alert.message = "Please enter a valid zip code."
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        PetFinderBreeds[self.breed!.BreedName] = nil
    }
    
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
        
        filterOptions.load()
        
        blurImage(UIImage(named: "Devon Rex")!)
        
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clearColor()

    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func blurImage(image2: UIImage) {
        /*
        let imageView = UIImageView(image: image2)
        imageView.frame = view.bounds
        imageView.contentMode = .ScaleToFill
        
        view.addSubview(imageView)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        
        self.view.sendSubviewToBack(blurredEffectView)
        self.view.sendSubviewToBack(imageView)
        */
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue=\(segue.identifier)")
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
            return "Breeds"
        case 1:
            return "Location"
        case 2:
            return "Administrative"
        case 3:
            return "Compatiblity"
        case 4:
            return "Personality"
        case 5:
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
        return 6
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            switch section {
            case 2:
                return filterOptions.adminList.count
            case 3:
                return filterOptions.compatibilityList.count
            case 4:
                return filterOptions.personalityList.count
            case 5:
                return filterOptions.physicalList.count
            default:
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var opt: filterOption?
        
        switch indexPath.section {
        case 2:
            opt = filterOptions.adminList[indexPath.row]
            break
        case 3:
            opt = filterOptions.compatibilityList[indexPath.row]
            break
        case 4:
            opt = filterOptions.personalityList[indexPath.row]
            break
        case 5:
            opt = filterOptions.physicalList[indexPath.row]
            break
        default:
            break
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("breeds", forIndexPath: indexPath) as! FilterOptionsBreedTableCell
            cell.breedLabel.text = "All Breeeds"
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("zipCode", forIndexPath: indexPath) as! FilterOptionsZipCodeTableCell
            cell.ZipCodeTextbox.delegate = self
            cell.ZipCodeTextbox.text = zipCode
            zipCodeTextField = cell.ZipCodeTextbox
            return cell
        } else if indexPath.section >= 2 {
            if opt!.list == true {
                let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath) as! FilterOptionsListTableCell
                cell.ListName.text = opt!.name
                cell.ListValue.text = opt?.getDisplayValues()
                return cell
            } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("options", forIndexPath: indexPath) as! FilterOptionsSegmentedTableCell
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
            let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
    func segmentValueChanged(sender: AnyObject?) {
        filterOptions.filteringOptions[sender!.tag].choosenValue = sender!.selectedIndex
    }
    
    var opt: filterOption?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section >= 2 {
            switch indexPath.section {
            case 2:
                opt = filterOptions.adminList[indexPath.row]
                break
            case 3:
                opt = filterOptions.compatibilityList[indexPath.row]
                break
            case 4:
                opt = filterOptions.personalityList[indexPath.row]
                break
            case 5:
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