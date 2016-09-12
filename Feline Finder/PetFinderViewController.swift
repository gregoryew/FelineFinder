//
//  PetFinder.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/3/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class PetFinderViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if breed?.BreedName == "All Breeds" {
            performSegueWithIdentifier("MainMenu", sender: nil)
        } else {
            performSegueWithIdentifier("MasterView", sender: nil)
        }
    }
    
    
    var breed: Breed?
    var pets: PetList?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var locationManager: CLLocationManager?
    var titles:[String] = []
    var totalRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        
        self.pets = PetFinderPetList()
        //self.pets = RescuePetList()
        
        self.navigationItem.title = "\(breed!.BreedName)"
        if (zipCode != "")
        {
            self.loadPets()
            setFilterDisplay()
        }
        else if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        setFilterDisplay()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if breed!.BreedName == "All Breeds" {
            self.navigationController?.setToolbarHidden(true, animated:true);
        } else {
            self.navigationController?.setToolbarHidden(false, animated:true);
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    /*
    func removeFilterLabel() {
        if let navigationBar = self.navigationController?.navigationBar {
            if let viewWithTag = navigationBar.viewWithTag(999) {
                viewWithTag.removeFromSuperview()
            } else {
                print("No!")
            }
        }
    }
    */
    
    func setFilterDisplay() {
        if let navigationBar = self.navigationController?.navigationBar {
            let filter = "Zip:\(zipCode) Filter:\(filterOptions.displayFilter())"
            navigationBar.topItem!.prompt = filter
        }
    }
    
    @IBAction func Refresh(sender: UIRefreshControl) {
        PetFinderBreeds[self.breed!.BreedName] = nil
        self.loadPets()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    @IBAction func unwindToPetFinderList(sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        setFilterDisplay()
        self.loadPets()
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (zipCode != "") {return}
        self.locationManager!.stopUpdatingLocation()
        if let loc = manager.location {
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error)->Void in
                if (error != nil) {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Reverse geocoder failed with error" + error!.localizedDescription
                    alert.addButtonWithTitle("Sorry")
                    alert.show()
                    //println("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    if let validPlacemark = placemarks?[0] {
                        let pm = validPlacemark
                        zipCode = pm.postalCode!
                        self.setFilterDisplay()
                    }
                    print("locationManager")
                    self.loadPets()
                } else {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Problem with the data received from geocoder"
                    alert.addButtonWithTitle("Sorry")
                    alert.show()
                    //println("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func loadPets() {
        self.pets! = RescuePetList()
        //self.pets! = PetFinderPetList()
        
        if let p = PetFinderBreeds[self.breed!.BreedName]
        {
            self.pets = p
        }
 
        let date = self.pets?.dateCreated
        
        let hoursSinceCreation: Int = NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: date!, toDate: NSDate(), options: []).hour
        
        var b = false
        
        if (self.pets!.count == 0) {
            b = true
        }
        
        if hoursSinceCreation > 24 {
            b = true
        }
        
        if b == true
        {
            self.tableView.reloadData()
            self.pets!.loadPets(self.tableView, bn: self.breed!, zipCode: zipCode) { (petList) -> Void in
                self.pets = petList
                self.totalRow = -1
                self.titles = self.pets!.distances.keys.sort{ $0 < $1 }
                PetFinderBreeds[self.breed!.BreedName] = self.pets
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        } else {
            self.totalRow = -1
            self.titles = self.pets!.distances.keys.sort{ $0 < $1 }
            self.tableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location \(error.localizedDescription)")
    }
    
    func totalRows(p: PetList) -> Int {
        var total = 0
        var i = 0
        if totalRow == -1 {
            while i < titles.count {
                total += self.pets!.distances[titles[i]]!.count
                i += 1
            }
            totalRow = total
        }
        return totalRow
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var t = 0
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                t = 1
            }
            else {
                t = self.titles.count
            }
        }
        return t
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        var t = ""
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                t = ""
            } else {
                t = titles[section].stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet()
                )
            }
        }
        return t
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var c = 0
        
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                c = 1
            } else {
                let sectionTitle = titles[section]
                c = self.pets!.distances[sectionTitle]!.count
                if (totalRows(p) % 25 == 0) && (section + 1 == self.pets!.distances.count)
                {
                    c = c + 1
                }
            }
        }
        
        return c
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PetFinderCell
        
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        
        
        cell.CatNameLabel!.highlightedTextColor = UIColor.whiteColor()
        cell.CatNameLabel!.textColor = UIColor.whiteColor()
        cell.CatNameLabel!.font = UIFont.boldSystemFontOfSize(14.0)
        
        cell.CatNameLabel!.backgroundColor = UIColor.clearColor()
        cell.CatNameLabel!.highlightedTextColor = UIColor.blackColor()
        cell.activityIndicator.hidden = true
        cell.activityIndicator.stopAnimating()
        cell.accessoryType = .None
        if titles.count == 0 || self.pets!.count == 0 {
           if pets!.loading {
                cell.CatImage?.hidden = true
                cell.CatNameLabel.text = "Loading please wait..."
                cell.activityIndicator.startAnimating()
                cell.activityIndicator.hidden = false
                return cell
            }
            else if self.pets!.count == 0 {
                cell.CatNameLabel.text = "There is no data."
                return cell
            }
        }
        
        //cell.accessoryView!.hidden = false
        cell.accessoryType = .DisclosureIndicator
        cell.CatImage?.hidden = false
        cell.lastCell = indexPath.row == self.pets!.distances[titles[indexPath.section]]!.count - 1
        //((CustomCellBackground *)cell.selectedBackgroundView).lastCell = indexPath.row == self.thingsToLearn.count - 1;
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRowsInSection(lastSectionIndex) - 1
        if (indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex) && totalRows(self.pets!) % 25 == 0 {
            cell.CatNameLabel!.text = "More..."
            cell.CatImage?.image = UIImage(named: "cat")
            return cell
        }
        
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        
        let urlString = petData.getImage(1, size: "pnt")
        
        let imgURL = NSURL(string: urlString)
        
        if petData.videos.count > 0 {
            cell.hasVideo.hidden = false
        } else {
            cell.hasVideo.hidden = true
        }
        
        cell.CatNameLabel!.text = petData.name
        
        cell.CatImage?.image = UIImage(named: "cat")
        
        if let img = imageCache[urlString] {
            cell.CatImage?.image = img
        }
        else {
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? PetFinderCell {
                                cellToUpdate.CatImage?.image = image
                            }
            })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
            })
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: PetFinderCell = tableView.cellForRowAtIndexPath(indexPath) as! PetFinderCell
        if selectedCell.CatNameLabel.text == "More..." {
            self.pets!.loadPets(self.tableView, bn: self.breed!, zipCode: zipCode) { (petList) -> Void in
                self.totalRow = -1
                self.pets = petList
                self.titles = self.pets!.distances.keys.sort{ $0 < $1 }
                PetFinderBreeds[self.breed!.BreedName] = self.pets
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var proceed = true
        if identifier == "petFinderDetail" {
            let indexPath = tableView.indexPathForSelectedRow;
            let currentCell = tableView.cellForRowAtIndexPath(indexPath!)! as! PetFinderCell;
            if currentCell.CatNameLabel.text == "More..."  || currentCell.CatNameLabel.text == "Loading please wait..." || currentCell.CatNameLabel.text == "There is no data." {
                proceed = false
            }
        }
        return proceed
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue=\(segue.identifier)")
        if segue.identifier == "searchOptions" {
            (segue.destinationViewController as! PetFinderFindViewController).breed = breed
        }
        else if segue.identifier == "BreedStats" {
            (segue.destinationViewController as! BreedStatsViewController).whichSeque = "BreedList"
            let b = self.breed as Breed?
            (segue.destinationViewController as! BreedStatsViewController).breed = b!
        }
        else if (segue.identifier == "showDetail") {
            let b = self.breed as Breed?
            (segue.destinationViewController as! DetailViewController).breed = b!
        }
        else if segue.identifier == "petFinderDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
                (segue.destinationViewController as! PetFinderViewDetailController).pet = petData
                (segue.destinationViewController as! PetFinderViewDetailController).petID = petData.petID
                (segue.destinationViewController as! PetFinderViewDetailController).petName = petData.name
                (segue.destinationViewController as! PetFinderViewDetailController).breedName = breed!.BreedName
            }
        }
    }
}

