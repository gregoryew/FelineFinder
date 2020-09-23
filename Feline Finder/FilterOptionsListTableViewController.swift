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
//import Alamofire

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
/*
extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}
*/
class FilterOptionsListTableViewController: UITableViewController, NavgationTransitionable {
    
    var txtfld: UITextField = UITextField()
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("FilterOptionsListTableViewController deinit")
    }
    
    @IBOutlet weak var SavedButton: UIBarButtonItem!
    var filterOpt: filterOption?
    var save: Bool = false
    
    @IBAction func ClearTapped(_ sender: Any) {
        filterOpt?.choosenListValues = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let index = Int(filterOptions.filteringOptions[0].options[indexPath.row].search!) ?? 0
            filterOptions.deleteSavedFilterValues(index)
            tableView.deleteRows(at: [indexPath], with: .fade)
            filterOptions.reset()
            currentFilterSave = "Touch Here To Load/Save..."
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        SavedButton.isEnabled = !editing
    }
    
    //hold this reference in your class
    weak var AddAlertSaveAction: UIAlertAction?
    
    var n = ""
    
    @IBAction func SavedTapped(_ sender: AnyObject) {
        promptUserForSaveName()
    }

    func saveFilter(name: String, overwrite: Bool, existingSaveID: Int) {
        currentFilterSave = name
        if overwrite {
            filterOptions.deleteSavedFilterValues(existingSaveID)
        }
        filterOptions.storeFilters(0, saveName: name)
        let c = filterOptions.filteringOptions[0].options.count + 1
        filterOptions.filteringOptions[0].options.append((displayName: name, search: String(NameID), value: c))
        _ = generateJSON()
        
        /*
        var request = URLRequest(url: URL(string: "http://127.0.0.1:4000/save")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //let pjson = json2.toJSONString(prettyPrint: false)
        let data = (json2.data(using: .utf8))! as Data
        
        request.httpBody = data
        
        Alamofire.request(request).responseJSON { (response) in
            
            
            print(response)
            
        }
        */
        _ = URL(string: "https://glacial-wave-88689.herokuapp.com/save")!
        //Alamofire.request(url, method: .post, parameters: ["json2":json2, "queryid":12, "userid": AppMisc.USER_ID]).responseString { (s) in print(s) }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.filterOpt!.options.count - 1, section: 0);
            self.tableView.reloadData()
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            self.filterOpt?.choosenValue = Int((self.filterOpt?.options[self.filterOpt!.options.count - 1].search)!)
            //indexPath.row
            currentFilterSave = (self.filterOpt?.options[self.filterOpt!.options.count - 1].displayName)!
            //filterOpt?.choosenListValues.append(indexPath.row)
            //performSegue(withIdentifier: "backToFilterOptions", sender: nil)
            _ = self.navigationController?.tr_popViewController()
        }
    }
    
    func generateJSON() -> String {
        var filters:[filter] = []
        
        filters += filterOptions.getFilters()
        
        filters.append(["fieldName": "animalStatus" as AnyObject, "operation": "notequals" as AnyObject, "criteria": "Adopted" as AnyObject])
        filters.append(["fieldName": "animalSpecies" as AnyObject, "operation": "equals" as AnyObject, "criteria": "cat" as AnyObject])
        filters.append(["fieldName": "animalLocationDistance" as AnyObject, "operation": "radius" as AnyObject, "criteria": distance as AnyObject])
        //print("Distance=\(distance)")
        filters.append(["fieldName": "animalLocation" as AnyObject, "operation": "equals" as AnyObject, "criteria": zipCode as AnyObject])
        if bnGlobal != "All Breeds" {
            filters.append(["fieldName": "animalPrimaryBreed" as AnyObject, "operation": "contains" as AnyObject, "criteria": bnGlobal as AnyObject])
        }
        var order = "desc"
        if sortFilter == "animalLocationDistance" {
            order = "asc"
        }
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": 0, "resultLimit": 100, "resultSort": sortFilter, "resultOrder": order, "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalBreed", "animalGeneralAge", "animalSex", "animalPrimaryBreed", "animalUpdatedDate", "animalOrgID", "animalLocationDistance" , "animalLocationCitystate", "animalPictures", "animalStatus", "animalBirthdate", "animalAvailableDate", "animalGeneralSizePotential", "animalVideoUrls"]]] as [String : Any]

        return Utilities.stringify(json: json, prettyPrinted: true);
    }
    
    func promptUserForSaveName() {
        let alertController = UIAlertController(title: "Search Name", message: "Please enter the name of the search", preferredStyle: .alert)
        
        // Add the text field with handler
        alertController.addTextField { textField in
            if currentFilterSave != "Touch Here To Load/Save..." {
                textField.text = currentFilterSave
            } else {
                textField.text = ""
            }
            self.txtfld = textField
        }
            
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            NSLog("Cancel Button Pressed");
        }
            
        let otherAction = UIAlertAction(title: "Save", style: .default) { action in
            NSLog("Save Button Pressed");
            self.n = self.txtfld.text!
            var duplicate = false
            for s in filterOptions.filteringOptions[0].options {
                if s.displayName == self.n {
                    duplicate = true
                    let alert = UIAlertController(title: "Overwrite Existing?", message: "A filter by this name already exists.  Do you want to overwrite or enter another name", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertAction.Style.destructive, handler: {action in
                        self.saveFilter(name: self.n, overwrite: true, existingSaveID: Int(s.search!)!)}))
                    alert.addAction(UIAlertAction(title: "Enter Another", style: UIAlertAction.Style.default, handler: {
                        action in
                        self.promptUserForSaveName()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            if !duplicate {self.saveFilter(name: self.n, overwrite: false, existingSaveID: -1)}
        }
        
        // save the other action to toggle the enabled/disabled state when the text changed.
        self.AddAlertSaveAction = otherAction
            
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        if filterOpt?.classification == .saves {
            SavedButton.title = "Save"
            SavedButton.isEnabled = true
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            if save {promptUserForSaveName()}
        } else {
            SavedButton.title = ""
            SavedButton.isEnabled = false
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
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
            filterOpt?.choosenValue = Int((filterOpt?.options[indexPath.row].search)!)
            //indexPath.row
            let cell = tableView.cellForRow(at: indexPath)
            currentFilterSave = (cell?.textLabel?.text)!
            //filterOpt?.choosenListValues.append(indexPath.row)
            //performSegue(withIdentifier: "backToFilterOptions", sender: nil)
            _ = navigationController?.tr_popViewController()
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
        return true
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
