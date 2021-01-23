//
//  FilterViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/20/20.
//

import UIKit

var rowHeights:Matrix<CGFloat> = Matrix(rows: 8, columns: 20,defaultValue:0)
var colapsed = [false,false,false,false,false]

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var filterTypeSegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        }
        
        configureTableView()
        
        filterOptions.load(self.tableView)
    }

/*
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
*/
    
    private func configureTableView() {
        tableView.allowsSelection = false
        tableView.register(
          FilterOptionTableViewCell.self,
          forCellReuseIdentifier: "list")
        tableView.register(
          FilterSectionLabelTableViewCell.self,
          forCellReuseIdentifier: "header")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.autoresizingMask = [.flexibleHeight]
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = FilterSectionLabelTableViewCell()
        if let header = tableView.dequeueReusableCell(withIdentifier: "header") as? FilterSectionLabelTableViewCell {
            header.config(section: section, tableView: self.tableView)
            return header
        }
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterType == .Simple {
            return 5
        } else {
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            if filterOptions.savesOption != nil {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {  //Breed
            if filterOptions.breedOption != nil {
                return 0
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        
        if indexPath.section == 0 { //Saved Searches
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
        } else if indexPath.section == 1 { //Breeds
            /*
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
            */
        } else if indexPath.section == 2 { //Zip Code
            if let cell = tableView.dequeueReusableCell(withIdentifier: "zipCode", for: indexPath) as? FilterOptionsZipCodeTableCell {
                cell.configure(zipCode: zipCode)
                return cell
            }
        } else { //Anything else
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section > 2 {
            return max(rowHeights[indexPath.section, indexPath.row], 35)
        } else {
            return 35
        }
    }
    
}
