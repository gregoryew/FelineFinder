//
//  FilterViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/20/20.
//

import UIKit

protocol FilterDismiss {
    func FilterDismiss(vc: UIViewController)
}

var rowHeights:Matrix<CGFloat> = Matrix(rows: 8, columns: 20,defaultValue:0)
var colapsed = [false,false,false,false,false]
var answers = Matrix(rows: 8, columns: 20, defaultValue: [Int]())

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Options, breedDisplay {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var filterTypeSegControl: UISegmentedControl!
    
    var observer3: Any!
    
    var delegate: FilterDismiss!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        hideKeyboardWhenTappedAround()
        
        filterOptions.load(self.tableView)
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
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
        return filterOptions.getList(section: section, colapsed: section < 3 ? false : colapsed[section - 3]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var opt: filterOption?
        let section = indexPath.section
        let catClass = catClassification(rawValue: section)
        
        opt = filterOptions.getList(section: section, colapsed: section < 3 ? false : colapsed[section - 3])[indexPath.row]
        
        switch catClass {
        case .saves:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.delegate = self
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
        case .breed:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.delegate = self
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
        case .zipCode:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "zipCode", for: indexPath) as? FilterOptionsZipCodeTableCell {
                cell.configure(zipCode: zipCode)
                return cell
            }
        default:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.delegate = self
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        var nextWidth = CGFloat(0.0)
        var width2 = CGFloat(0)
        //var col = 0
        if section != 2 {
            let opt = filterOptions.getList(section: section, colapsed: section < 3 ? false : colapsed[section - 3])[indexPath.row]
            let contentWidth = tableView.frame.width - 130
            let columnHeight: CGFloat = 50
            var yOffsets = [CGFloat]()
            var xOffsets = [CGFloat]()
            var row = -1
            var item2 = 0
            let itemCount = opt.options.count
            while item2 < itemCount {
                row += 1
                yOffsets.append(CGFloat(row) * (columnHeight - 10))
                xOffsets.append(0)
                nextWidth = CGFloat(0.0)
                while (item2 < itemCount) && (xOffsets[row] + nextWidth < contentWidth)
                {
                    width2 = (opt.options[item2].displayName?.SizeOf(UIFont.systemFont(ofSize: 16)).width ?? 0) + 50
                    
                    if (item2 == itemCount) && (xOffsets[row] + width2 > contentWidth) {
                        row += 1
                        //yOffsets.append(CGFloat(row) * columnHeight)
                        xOffsets.append(0)
                        nextWidth = CGFloat(0.0)
                    }

                    xOffsets[row] = xOffsets[row] + width2
                    if item2 < itemCount - 1 {
                        nextWidth = (opt.options[item2 + 1].displayName?.SizeOf(UIFont.systemFont(ofSize: 16)).width ?? 0) + 50
                    } else {
                        nextWidth = 0
                    }
                    item2 += 1
                }
            }
            return (yOffsets.last ?? 0) + columnHeight + (row > 0 ? 5 : 0)
        } else {
            return 50
        }
    }
    
    func answerChanged(indexPath: IndexPath, answer: Int) {
        let section = indexPath.section
        let opt = filterOptions.getList(section: section, colapsed: section < 3 ? false : colapsed[section - 3])[indexPath.row]
        if (opt.list ?? false) && (opt.options[answer].displayName != "Any") {
            if let _ = answers[indexPath.section, indexPath.row].firstIndex(of: answer) {
                answers[indexPath.section, indexPath.row].remove(object: answer)
            } else {
                if (answers[indexPath.section, indexPath.row].count > 0) && (opt.options.last!.displayName == "Any") {
                    answers[indexPath.section, indexPath.row].removeLast()
                }
                answers[indexPath.section, indexPath.row].append(answer)
            }
        } else {
            answers[indexPath.section, indexPath.row].removeAll()
            answers[indexPath.section, indexPath.row].append(answer)
        }
        if opt.classification == .breed {
            if answer == filterOptions.filteringOptions[1].options.count - 1 {
                let breedsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedsViewController") as! BreedsViewController
                breedsVC.modalPresentationStyle = .formSheet
                breedsVC.delegate = self
                    //fitDialogVC.image = question?.ImageName ?? ""
                self.present(breedsVC, animated: false, completion: nil)
                selected = [Bool](repeating: false, count: filterOptions.breedChoices.count)
                for o in opt.options {
                    if o.displayName != "Add..." {
                        for i in 0..<filterOptions.breedChoices.count {
                            if o.displayName == filterOptions.breedChoices[i].displayName {
                                selected[i] = true
                                break
                            }
                        }
                    }
                }
            }
        } else if opt.classification == .saves {
            filterOptions.retrieveSavedFilterValues(Int(opt.options[answer].search ?? "0")!, filterOptions: filterOptions)
            filterOptions.classify()
            answers = Matrix(rows: 8, columns: 20, defaultValue: [Int]())
            var prevSection: catClassification = .saves
            var currentItem = 0
            for o in filterOptions.filteringOptions {
                if o.classification == .saves {
                    answers[catClassification.saves.rawValue, 0].append(answer)
                } else {
                    if prevSection != o.classification {
                        currentItem = 0
                        prevSection = o.classification
                    } else {
                        currentItem += 1
                    }
                    if o.list == false {
                        answers[o.classification.rawValue, currentItem].append(o.choosenValue ?? 0)
                    } else {
                        answers[o.classification.rawValue, currentItem].append(contentsOf: o.choosenListValues)
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    func dismissed(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func deleteSave(save: Int) {
        let alert = UIAlertController(title: "Delete Save?", message: "Do you want to delete this saved filter?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            filterOptions.deleteSavedFilterValues(save)
            filterOptions.filteringOptions[0].options.removeAll { (listOption) -> Bool in
                Int(listOption.search ?? "0")! == save
            }
            if filterOptions.filteringOptions[0].options.count > 0 {
                answers[0, 0].removeAll()
                answers[0, 0].append(filterOptions.filteringOptions[0].options.count - 1)
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }))

        // 4. Cancel
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        // 5. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveFilterTapped(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Save Filter As", message: "Enter a save name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            if filterOptions.filteringOptions[0].choosenValue != nil {
                let name = filterOptions.filteringOptions[0].options.filter { (listOption) -> Bool in
                    if answers[0, 0].count > 0 {
                        return Int(listOption.search ?? "0")! == Int(filterOptions.filteringOptions[0].options[answers[0, 0][0]].search ?? "0")!
                    } else {
                        return false
                    }
                }
                if name.count > 0 {
                    textField.text = name[0].displayName
                } else {
                    textField.text = ""
                }
            }
            textField.placeholder = "Name"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let savedName = alert?.textFields![0].text ?? "Saved Filter"
            var prevSection: catClassification = .saves
            var currentItem = 0
            for o in filterOptions.filteringOptions {
                if o.classification != .saves {
                    if prevSection != o.classification {
                        currentItem = 0
                        prevSection = o.classification
                    } else {
                        currentItem += 1
                    }
                    if o.list == false {
                        if answers[o.classification.rawValue, currentItem].count > 0 {
                            o.choosenValue = answers[o.classification.rawValue, currentItem][0]
                        }
                    } else {
                        o.choosenListValues = []
                        var breeds: [Int] = []
                        if o.classification == .breed {
                            for ans in answers[1,0] {
                                let rescueID = filterOptions.breedChoices.filter { (listOption) -> Bool in
                                    listOption.displayName == filterOptions.filteringOptions[1 ].options[ans].displayName
                                }
                                if rescueID.count > 0 {
                                    breeds.append(Int(rescueID[0].search ?? "0") ?? 0)
                                }
                                o.choosenListValues.append(contentsOf: breeds)
                            }
                        } else {
                            o.choosenListValues.append(contentsOf: answers[o.classification.rawValue, currentItem])
                        }
                    }
                }
            }
            let exists = filterOptions.filteringOptions[0].options.filter { (listOption) -> Bool in
                listOption.displayName == savedName
            }
            if exists.count > 0 {
                let alert2 = UIAlertController(title: "Overwrite?", message: "\(savedName) already exists.  Do you want me to overwrite that save?", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    filterOptions.storeFilters(Int(exists[0].search ?? "0")!, saveName: savedName)
                }))
                
                // 4. Cancel
                alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                // 5. Present the alert.
                self.present(alert2, animated: true, completion: nil)
            } else {
                filterOptions.storeFilters(0, saveName: savedName)
                let lo = listOption(displayName: savedName, search: String(NameID), value: NameID)
                filterOptions.filteringOptions[0].options.append(lo)
                answers[0, 0].removeAll()
                answers[0, 0].append(filterOptions.filteringOptions[0].options.count - 1)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }))

        // 4. Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // 5. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func showResultsTapped(_ sender: Any) {
        if !DatabaseManager.sharedInstance.validateZipCode(zipCode: zipCode) {
            let alert = UIAlertController(title: "Invalid Zipcode", message: "Please enter a valid zipcode.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            delegate.FilterDismiss(vc: self)
        }
    }
}
