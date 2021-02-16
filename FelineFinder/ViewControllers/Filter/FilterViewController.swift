//
//  FilterViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/20/20.
//

import UIKit

var rowHeights:Matrix<CGFloat> = Matrix(rows: 8, columns: 20,defaultValue:0)
var colapsed = [false,false,false,false,false]
var answers:Matrix<[Int]>!

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Options {
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
        
        answers = Matrix(rows: 8, columns: 20, defaultValue: [Int]())
        
        configureTableView()
                
        filterOptions.load(self.tableView)
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
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
        case .breed:
            break
            /*
            if let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as? FilterOptionTableViewCell {
                cell.configure(option: opt!, indexPath: indexPath)
                return cell
            }
            */
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
        if section > 2 {
            if rowHeights[section, indexPath.row] == 0 {
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
                    yOffsets.append(CGFloat(row) * columnHeight)
                    xOffsets.append(0)
                    nextWidth = CGFloat(0.0)
                    while (item2 < itemCount) && (xOffsets[row] + nextWidth < contentWidth) {
                        width2 = (opt.options[item2].displayName?.SizeOf(UIFont.systemFont(ofSize: 16)).width ?? 0) + 30
                        
                        if (item2 == itemCount) && (xOffsets[row] + width2 > contentWidth) {
                            row += 1
                            yOffsets.append(CGFloat(row) * columnHeight)
                            xOffsets.append(0)
                            nextWidth = CGFloat(0.0)
                        }

                        xOffsets[row] = xOffsets[row] + width2
                        if item2 < itemCount - 1 {
                            nextWidth = (opt.options[item2 + 1].displayName?.SizeOf(UIFont.systemFont(ofSize: 16)).width ?? 0) + 30
                        } else {
                            nextWidth = 0
                        }
                        item2 += 1
                    }
                }
                rowHeights[indexPath.section, indexPath.row] = (yOffsets.last ?? 0) + columnHeight + (row > 0 ? 5 : 0)
                return rowHeights[indexPath.section, indexPath.row]
            } else {
                return rowHeights[indexPath.section, indexPath.row]
            }
        } else {
            return 35
        }
    }
    
    func answerChanged(indexPath: IndexPath, answer: Int) {
        let section = indexPath.section
        let opt = filterOptions.getList(section: section, colapsed: section < 3 ? false : colapsed[section - 3])[indexPath.row]
        if (opt.list ?? false) && (opt.options[answer].displayName != "Any") {
            if let _ = answers[indexPath.section, indexPath.row].firstIndex(of: answer) {
                answers[indexPath.section, indexPath.row].remove(object: answer)
            } else {
                if (answers[indexPath.section, indexPath.row].count > 0) && (opt.options[answers[indexPath.section, indexPath.row].last ?? 0].displayName == "Any") {
                    answers[indexPath.section, indexPath.row].removeLast()
                }
                answers[indexPath.section, indexPath.row].append(answer)
            }
        } else {
            answers[indexPath.section, indexPath.row].removeAll()
            answers[indexPath.section, indexPath.row].append(answer)
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    @IBAction func showResultsTapped(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
            globalBreed = breed
            PetFinderBreeds[(globalBreed?.BreedName)! + "_ADOPT"] = nil
            self.dismiss(animated: false, completion: nil)
            DownloadManager.loadPetList(reset: true)
        })
    }
    
}
