//
//  BreedsViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/11/21.
//

import UIKit

protocol breedDisplay {
    func dismissed(vc: UIViewController)
}

struct BreedListItem {
    let breedName: String
    let breedImageName: String
    let breedID: Int
    init (breedName: String, breedImageName: String,
          breedID: Int) {
        self.breedName = breedName
        self.breedImageName = breedImageName
        self.breedID = breedID
    }
}

var selected: [Bool] = []

class BreedsViewController: ParentViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var backButton: UIButton!
    
    var delegate: breedDisplay?
    
    var breedChoices: [BreedListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var breedsList: Dictionary<String, [Breed]> = [:]
        DatabaseManager.sharedInstance.fetchBreeds(false) { (breeds) -> Void in
            breedsList = breeds
            self.breedChoices = []
            var i = 0
            let titles: [String] = breedsList.keys.sorted{$0 < $1}
            for t in titles {
                let data = breedsList[t]
                var j = 0
                while j < data!.count {
                    let b = data![j]
                    self.breedChoices.append(BreedListItem(breedName: b.BreedName, breedImageName: "Cartoon \(b.BreedName)", breedID: Int(b.RescueBreedID) ?? 0))
                    i += 1
                    j += 1
                }
            }
            if selected.count == 0 {selected = [Bool](repeating: false, count: self.breedChoices.count)}
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }

        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.breedChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell") as? BreedTableViewCell {
            cell.tag = indexPath.row
            cell.configure(breed: breedChoices[indexPath.row])
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "BreedCell") as! BreedTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected[indexPath.row] = !selected[indexPath.row]
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func selectedTapped(_ sender: Any) {
        var breedIDs: [Int] = []
        var breeds: [listOption] = []
        var choosenValues: [Int] = []
        var count = 0
        for i in 0..<selected.count {
            if selected[i] {
                breedIDs.append(count)
                breeds.append(listOption(displayName: breedChoices[i].breedName, search: String(breedChoices[i].breedID), value: 0))
                choosenValues.append(breedChoices[i].breedID)
                count += 1
            }
        }
        breedIDs.append(0)
        breeds.append(listOption(displayName: "Add...", search: "0", value: 1))

        answers[1, 0].removeAll()
        answers[1, 0].append(contentsOf: breedIDs)
        filterOptions.filteringOptions[1].options.removeAll()
        filterOptions.filteringOptions[1].options.append(contentsOf: breeds)
        filterOptions.filteringOptions[1].choosenListValues.removeAll()
        filterOptions.filteringOptions[1].choosenListValues.append(contentsOf: choosenValues)
        delegate?.dismissed(vc: self)
    }
    
}
