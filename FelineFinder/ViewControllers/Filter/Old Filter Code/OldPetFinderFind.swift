//
//  PetFinderFind.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/9/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import BetterSegmentedControl

var observer3: Any?

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

extension UITableView {

    func isLast(for indexPath: IndexPath) -> Bool {

        let indexOfLastSection = numberOfSections > 0 ? numberOfSections - 1 : 0
        let indexOfLastRowInLastSection = numberOfRows(inSection: indexOfLastSection) - 1

        return indexPath.section == indexOfLastSection && indexPath.row == indexOfLastRowInLastSection
    }
}

class PetFinderFindViewController: UITableViewController, UITextFieldDelegate {
    deinit {
        print ("PetFinderFindViewController deinit")
    }
    
    var colapsed = [true,true,true,true,true]
        
    @IBOutlet weak var clear: UIBarButtonItem!
    
    lazy var sideBar: UIView = {
        let toolBarView = UIView(frame: CGRect(x: self.view.frame.width - 100, y: 20, width: 100, height: 50))
        toolBarView.backgroundColor = .green
        toolBarView.layer.shadowRadius = 5
        toolBarView.layer.shadowOpacity = 0.8
        toolBarView.layer.shadowOffset = CGSize(width: 5, height: 5)

        let searchBtn = UIButton(type: .roundedRect)
        searchBtn.setAttributedTitle(setEmojicaLabel(text: "🔎"), for: .normal)
        toolBarView.addSubview(searchBtn)
        searchBtn.addTarget(self, action: #selector(DoneTapped), for:  .touchUpInside)
        searchBtn.frame = CGRect(x: 5, y: 5, width: 40, height: 40)

        let clearBtn = UIButton(type: .roundedRect)
        clearBtn.setAttributedTitle(setEmojicaLabel(text: "🗑️"), for: .normal)
        toolBarView.addSubview(clearBtn)
        clearBtn.addTarget(self, action: #selector(clearTapped), for:  .touchUpInside)
        clearBtn.frame = CGRect(x: searchBtn.frame.minX + searchBtn.frame.width + 5, y: 5, width: 40, height: 40)
        
        return toolBarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.addSubview(sideBar)
        
        let nc = NotificationCenter.default
        observer3 = nc.addObserver(forName:listReturned, object:nil, queue:nil) { [weak self] notification in
                        
            if let sourceViewController = notification.object as? FilterOptionsListTableViewController {
            //let sourceViewController = sender.source as! FilterOptionsListTableViewController
            var i = 0
                if sourceViewController.filterOpt?.classification == .saves {
                    if (sourceViewController.filterOpt?.choosenValue)! >= 0 {
                        filterOptions.retrieveSavedFilterValues((sourceViewController.filterOpt?.choosenValue)!, filterOptions: filterOptions) //, choosenListValues: (sourceViewController.filterOpt?.choosenListValues)!)
                }
            }
            for o in filterOptions.filteringOptions {
                if sourceViewController.filterOpt?.name == o.name {
                    filterOptions.filteringOptions[i].choosenListValues = (sourceViewController.filterOpt?.choosenListValues)!
                }
                i += 1
            }}
            
            DispatchQueue.main.async(execute: {
                self?.tableView.reloadData()
            })
        }
        
        configureTableView()

        filterOptions.load(self.tableView)
                        
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = lightBackground
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sideBar.frame = CGRect(x: self.view.frame.width - 100, y: scrollView.contentOffset.y + 20, width: 100, height: 50);
        view.bringSubviewToFront(sideBar)
    }
    
    private func configureTableView() {
        tableView.allowsSelection = false
        tableView.register(
          FilterOptionsListTableCell.self,
          forCellReuseIdentifier: "list")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.autoresizingMask = [.flexibleHeight]
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
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
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func DoneTapped(_ sender: AnyObject) {
        //PetFinderBreeds[bnGlobal] = nil
        //bnGlobal = ""
        //zipCodeGlobal = ""
        zipCode = zipCodeTextField!.text!

        if validateZipCode(zipCode) == false {
            Utilities.displayAlert("Invalid Zip Code", errorMessage: "Please enter a valid zip code.")
        } else {
            let keyStore = NSUbiquitousKeyValueStore()
            keyStore.set(zipCode, forKey: "zipCode")
            sourceViewController = nil
            viewPopped = true
            presentingViewController?.dismiss(animated: false) {
                let nc = NotificationCenter.default
                nc.post(name:filterReturned,
                        object: nil,
                        userInfo:nil)
            }
        }
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
            
    @objc func didTapDone(sender: AnyObject) {
        //zipCodeGlobal = (zipCodeTextField?.text!)!
        zipCode = (zipCodeTextField?.text!)!
        zipCodeTextField?.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = lightBackground
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if segue.identifier == "goToPetFinderList" {
        //    (segue.destination as! PetFinderViewController).breed = breed
        //} else
        if segue.identifier == "chooseFilterOptions" {
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
        if section >= 4 {
            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(headerTapped(_:))
            )
            let title = self.tableView(tableView, titleForHeaderInSection: section)
            header.titleLabel.text = title ?? ""
            let label = (colapsed[section - 4] ? "➡️ " : "⬇️ ") + (title ?? "")
            header.titleLabel.attributedText = setEmojicaLabel(text: label, size: header.titleLabel.font.pointSize, fontName: header.titleLabel.font.fontName)
            header.tag = section
            header.addGestureRecognizer(tapGestureRecognizer)
        }
        return header
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        guard let section = sender?.view?.tag else { return }

        if section > 3 {
            let header = sender?.view as! CustomHeader
            let title = self.tableView(self.tableView, titleForHeaderInSection: section)
            colapsed[section - 4] = colapsed[section - 4] ? false : true
            let label = (colapsed[section - 4] ? "➡️ " : "⬇️ ") + (title ?? "")
            header.titleLabel.attributedText = setEmojicaLabel(text: label, size: header.titleLabel.font.pointSize, fontName: header.titleLabel.font.fontName)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
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
                    return colapsed[0] ? 1 : filterOptions.basicList.count
                } else {
                    print("adminList \(filterOptions.adminList.count)")
                    return colapsed[0] ? 1 : filterOptions.adminList.count
                }
            case 5:
                return colapsed[1] ? 1 : filterOptions.compatibilityList.count
            case 6:
                return colapsed[2] ? 1 :filterOptions.personalityList.count
            case 7:
                return colapsed[3] ? 1 :filterOptions.physicalList.count
            default:
                return 0
            }
        }
    }
        
    func getChoosenValues(section: catClassification) -> String {
        var choosen = ""
        for filterOption in filterOptions.filteringOptions {
            if filterOption.classification != section {continue}
            if filterOption.choosenListValues.count > 0 || filterOption.choosenValue != filterOption.options.count - 1 {
                if filterOption.choosenListValues.count > 0 {
                    choosen = ("\(choosen), 🔎 \(filterOption.name ?? "")")
                } else {
                    if (filterOption.options[filterOption.choosenValue!] ).displayName == "Yes" {
                        choosen = ("\(choosen), 🔎 \(filterOption.name ?? "")")
                    } else if (filterOption.options[filterOption.choosenValue!] ).displayName == "No" {
                        choosen = ("\(choosen), 🔎 Not \(filterOption.name ?? "")")
                    } else {
                        choosen = ("\(choosen), 🔎 \(filterOption.name ?? "") : \(String(describing: filterOption.options[filterOption.choosenValue!] .displayName!))")
                    }
                }
            }
        }
        return choosen == "" ? "None" : choosen.chopPrefix(2)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var opt: filterOption?
        var colapsedOpt = false

        if indexPath.section > 3 {
            colapsedOpt = colapsed[indexPath.section - 4]
            if colapsedOpt {
               let catClass = catClassification(rawValue: indexPath.section - 1)
               let opt1 = [listOption(displayName: "Test \(indexPath.section - 3)", search: "", value: 0)]
               opt = filterOption(n: "Chosen", f: "Chosen", d: true, c: catClass!, l: true, o: opt1, ft: FilterType.Simple)
            }
        }
        
        if (!colapsedOpt) {
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
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.ListName.text = opt!.name!
            cell.ListValue.text = currentFilterSave
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.ListName.text = opt!.name
            cell.ListValue.text = opt?.getDisplayValues()
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zipCode", for: indexPath) as! FilterOptionsZipCodeTableCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.ZipCodeTextbox.delegate = self
            cell.ZipCodeTextbox.text = zipCode
            zipCodeTextField = cell.ZipCodeTextbox
            return cell
        } else if indexPath.section >= 3 {
            if opt!.list == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! FilterOptionsListTableCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.ListName.text = opt!.name
                if (!colapsedOpt) {
                    cell.ListValue.text = opt?.getDisplayValues()
                } else {
                    cell.ListValue.attributedText = setEmojicaLabel(text: getChoosenValues(section: catClassification(rawValue: indexPath.section - 1)!), size: cell.ListValue.font.pointSize)
                }
                cell.ListValue.isUserInteractionEnabled = true
                if (opt?.imported)! {
                    cell.ListName.textColor = UIColor.red
                } else {
                    cell.ListName.textColor = textColor
                }
                return cell
            } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "options", for: indexPath) as! FilterOptionsSegmentedTableCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.OptionLabel.text = opt!.name
                cell.OptionSegmentedControl.segments = LabelSegment.segments(withTitles: opt!.optionsArray(),
                                                                         normalFont: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
                                                                         normalTextColor: .white,
                                                                         selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!,
                                                                         selectedTextColor: .black)
                    //= opt!.optionsArray()
            //cell.OptionSegmentedControl.font = UIFont(name: "Avenir-Black", size: 12)
            //cell.OptionSegmentedControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
            if let cv = opt!.choosenValue {
                cell.OptionSegmentedControl.setIndex(cv, animated: true)
            }
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
    
    @objc func segmentValueChanged(_ sender: AnyObject?) {
        filterOptions.filteringOptions[sender!.tag].choosenValue = (sender as! BetterSegmentedControl).index
        if (sender!.tag == 4) {
            opt = filterOptions.sortByList[3]
            if opt?.choosenValue == 1 {
                filterType = FilterType.Advanced
            } else {
                filterType = FilterType.Simple
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
                present(listOptions, animated: false, completion: nil)
                //navigationController?.tr_pushViewController(listOptions, method: DemoTransition.Slide(direction: DIRECTION.left))
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
