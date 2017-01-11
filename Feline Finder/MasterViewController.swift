//
//  MasterViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var breeds: Dictionary<String, [Breed]> = [:]
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101:"");
    var whichSeque: String = ""
    var breedStat: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101: "")
    var titles:[String] = []
    
    @IBAction func goBackTapped(_ sender: AnyObject) {
        if whichSeque == "results" {
            performSegue(withIdentifier: "Choices", sender: nil)
        } else {
            performSegue(withIdentifier: "MainMenu", sender: nil)
        }
    }
    
    @IBAction func unwindToMasterView(_ sender: UIStoryboardSegue)
    {
        /*
        if sender.sourceViewController is PetFinderViewController {
            let sourceViewController = sender.sourceViewController as! PetFinderViewController
            sourceViewController.removeFilterLabel()
        }
        */
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        
        if (whichSeque == "results")
        {
            DatabaseManager.sharedInstance.fetchBreeds(true) { (breeds) -> Void in
                self.titles = breeds.keys.sorted{ $0 < $1 }
                self.breeds = breeds
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
                self.title = "Matches"
            }
        }
        else {
            DatabaseManager.sharedInstance.fetchBreeds(false) { (breeds) -> Void in
                self.titles = breeds.keys.sorted{ $0 < $1 }
                self.breeds = breeds
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                self.title = "Breeds"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let breed = breeds[titles[indexPath.section]]![indexPath.row]
                (segue.destination as! DetailViewController).breed = breed
                filterOptions.reset()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = titles[section]
        return breeds[sectionTitle]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MasterViewCell)

        let breed = breeds[titles[indexPath.section]]![indexPath.row]
        
        //cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        /*
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        */
        
        cell.backgroundColor = UIColor.black
        
        cell.CatNameLabel.backgroundColor = UIColor.clear
        cell.CatNameLabel.highlightedTextColor = UIColor.white
        cell.CatNameLabel.textColor = UIColor.white
        cell.CatNameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        cell.accessoryType = .disclosureIndicator
        //cell.accessoryView!.hidden = false
        cell.lastCell = indexPath.row == self.breeds[titles[indexPath.section]]!.count - 1
        //((CustomCellBackground *)cell.selectedBackgroundView).lastCell = indexPath.row == self.thingsToLearn.count - 1;
        
        //let lastSectionIndex = tableView.numberOfSections - 1
        //let lastRowIndex = tableView.numberOfRowsInSection(lastSectionIndex) - 1
        
        if (breed.PercentMatch != -1) {
            cell.CatNameLabel.text = "\(breed.PercentMatch)% \(breed.BreedName)"
        }
        else {
            cell.CatNameLabel.text = breed.BreedName
        }
        
        cell.CatImage.image = UIImage(named: breed.PictureHeadShotName)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let trimmedString = titles[section].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        return trimmedString
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        breedStat = breeds[titles[indexPath.section]]![indexPath.row]
        self.performSegue(withIdentifier: "BreedStats", sender: nil)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if whichSeque != "results" {
            return titles
        } else {
            return []
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if whichSeque != "results" {
            let temp = titles as NSArray
            return temp.index(of: title)
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = UIColor(red:0.51, green:0.73, blue:0.84, alpha:1.0)
        header.darkColor = UIColor(red:0.51, green:0.73, blue:0.84, alpha:1.0)
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

}

