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
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0");
    var whichSeque: String = ""
    var breedStat: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0")
    var titles:[String] = []
    
    @IBAction func goBackTapped(sender: AnyObject) {
        if whichSeque == "results" {
            performSegueWithIdentifier("Choices", sender: nil)
        } else {
            performSegueWithIdentifier("MainMenu", sender: nil)
        }
    }
    
    @IBAction func unwindToMasterView(sender: UIStoryboardSegue)
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
                self.titles = breeds.keys.sort{ $0 < $1 }
                self.breeds = breeds
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                self.title = "Matches"
            }
        }
        else {
            DatabaseManager.sharedInstance.fetchBreeds(false) { (breeds) -> Void in
                self.titles = breeds.keys.sort{ $0 < $1 }
                self.breeds = breeds
                dispatch_async(dispatch_get_main_queue(), {
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let breed = breeds[titles[indexPath.section]]![indexPath.row]
            (segue.destinationViewController as! DetailViewController).breed = breed
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.titles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = titles[section]
        return breeds[sectionTitle]!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MasterViewCell)

        let breed = breeds[titles[indexPath.section]]![indexPath.row]
        
        //cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        
        cell.CatNameLabel.backgroundColor = UIColor.clearColor()
        cell.CatNameLabel.highlightedTextColor = UIColor.whiteColor()
        cell.CatNameLabel.textColor = UIColor.whiteColor()
        cell.CatNameLabel.font = UIFont.boldSystemFontOfSize(14.0)
        
        cell.accessoryType = .DisclosureIndicator
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

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let trimmedString = titles[section].stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return trimmedString
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        breedStat = breeds[titles[indexPath.section]]![indexPath.row]
        self.performSegueWithIdentifier("BreedStats", sender: nil)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if whichSeque != "results" {
            return titles
        } else {
            return []
        }
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if whichSeque != "results" {
            let temp = titles as NSArray
            return temp.indexOfObject(title)
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}

