//
//  BreedsViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/11/21.
//

import UIKit

struct BreedListItem {
    let breedName: String
    let breedImageName: String
    var selected: Bool = false
    init (breedName: String, breedImageName: String, selected: Bool) {
        self.breedName = breedName
        self.breedImageName = breedImageName
        self.selected = false
    }
}

class BreedsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var backButton: UIButton!
    
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
                    self.breedChoices.append(BreedListItem(breedName: b.BreedName, breedImageName: "Cartoon \(b.BreedName)",
                        selected: false))
                    i += 1
                    j += 1
                }
            }
        }

        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.breedChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell") as? BreedTableViewCell {
            cell.configure(breed: breedChoices[indexPath.row])
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "BreedCell") as! BreedTableViewCell
    }
    
}
