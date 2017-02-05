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
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if breed?.BreedName == "All Breeds" {
            performSegue(withIdentifier: "MainMenu", sender: nil)
        } else {
            performSegue(withIdentifier: "MasterView", sender: nil)
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setFilterDisplay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if breed!.BreedName == "All Breeds" {
            self.navigationController?.setToolbarHidden(true, animated:false);
        } else {
            self.navigationController?.setToolbarHidden(false, animated:false);
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:false);
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
            let filter = "Zip:\(zipCode)"
            navigationBar.topItem!.prompt = filter
        }
    }
    
    @IBAction func Refresh(_ sender: UIRefreshControl) {
        zipCodeGlobal = ""
        PetFinderBreeds[self.breed!.BreedName] = nil
        self.loadPets()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    @IBAction func unwindToPetFinderList(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        setFilterDisplay()
        self.loadPets()
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (zipCode != "") {
            return
        }
        self.locationManager!.stopUpdatingLocation()
        if let loc = manager.location {
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error)->Void in
                if (error != nil) {
                    Utilities.displayAlert("Alert", errorMessage: "Reverse geocoder failed with error " + error!.localizedDescription)
                    //println("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    if let validPlacemark = placemarks?[0] {
                        let pm = validPlacemark
                        zipCode = pm.postalCode!
                        self.setFilterDisplay()
                        print("locationManager")
                        if (zipCode != "") {
                            self.loadPets()
                        }
                    }
                } else {
                    Utilities.displayAlert("Alert", errorMessage: "Problem with the data received from geocoder")
                    //println("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func loadPets() {
    
        /*self.pets! = RescuePetList()
        //self.pets! = PetFinderPetList()
        
        if let p = PetFinderBreeds[self.breed!.BreedName]
        {
            self.pets = p
        }
 
        let date = self.pets?.dateCreated
        
        let hoursSinceCreation: Int = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: date! as Date, to: Date(), options: []).hour!
        
        var b = false
        
        if (self.pets!.count == 0) {
            b = true
        }
        
        if hoursSinceCreation > 24 {
            b = true
        }
        /*
        if b == true
        {
            self.tableView.reloadData()
            self.pets!.loadPets(self.collectionView, bn: self.breed!, zipCode: zipCode) { (petList) -> Void in
                self.pets = petList
                self.totalRow = -1
                self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                PetFinderBreeds[self.breed!.BreedName] = self.pets
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } else {
            self.totalRow = -1
            self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
            self.tableView.reloadData()
        }
        */
 */
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location \(error.localizedDescription)")
    }
    
    func totalRows(_ p: PetList) -> Int {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        var t = ""
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                t = ""
            } else {
                t = titles[section].trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines
                )
            }
        }
        return t
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PetFinderCell
        
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
            let selectedBackgroundCell = CustomCellBackground()
            cell.selectedBackgroundView = selectedBackgroundCell
        }
        
        
        cell.CatNameLabel!.highlightedTextColor = UIColor.white
        cell.CatNameLabel!.textColor = UIColor.white
        cell.CatNameLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        cell.CatNameLabel!.backgroundColor = UIColor.clear
        cell.CatNameLabel!.highlightedTextColor = UIColor.black
        cell.activityIndicator.isHidden = true
        cell.activityIndicator.stopAnimating()
        cell.accessoryType = .none
        if titles.count == 0 || self.pets!.count == 0 {
           if pets!.loading {
                cell.CatImage?.isHidden = true
                cell.CatNameLabel.text = "Loading please wait..."
                cell.activityIndicator.startAnimating()
                cell.activityIndicator.isHidden = false
                return cell
            }
            else if self.pets!.count == 0 {
                cell.CatNameLabel.text = "There is no data."
                return cell
            }
        }
        
        //cell.accessoryView!.hidden = false
        cell.accessoryType = .disclosureIndicator
        cell.CatImage?.isHidden = false
        cell.lastCell = indexPath.row == self.pets!.distances[titles[indexPath.section]]!.count - 1
        //((CustomCellBackground *)cell.selectedBackgroundView).lastCell = indexPath.row == self.thingsToLearn.count - 1;
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if (indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex) && totalRows(self.pets!) % 25 == 0 {
            cell.CatNameLabel!.text = "More..."
            cell.CatImage?.image = UIImage(named: "Cat")
            return cell
        }
        
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        
        let urlString = petData.getImage(1, size: "pnt")
        
        let imgURL = URL(string: urlString)
        
        if petData.videos.count > 0 {
            cell.hasVideo.isHidden = false
        } else {
            cell.hasVideo.isHidden = true
        }
        
        cell.CatNameLabel!.text = petData.name
        
        cell.CatImage?.image = UIImage(named: "Cat")
        
        if let img = imageCache[urlString] {
            cell.CatImage?.image = img
        }
        else {
            let request: URLRequest = URLRequest(url: imgURL!)
            _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Update the cell
                    DispatchQueue.main.async(execute: {
                        if let cellToUpdate = tableView.cellForRow(at: indexPath) as? PetFinderCell {
                                cellToUpdate.CatImage?.image = image
                            }
                    })
                }
                else {
                    print("Error: \(error!.localizedDescription)")
                }
            }).resume()
        }
        
        return cell
    }
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: PetFinderCell = tableView.cellForRow(at: indexPath) as! PetFinderCell
        if selectedCell.CatNameLabel.text == "More..." {
            zipCodeGlobal = ""
            bnGlobal = ""
            self.pets!.loadPets(self.tableView, bn: self.breed!, zipCode: zipCode) { (petList) -> Void in
                self.totalRow = -1
                self.pets = petList
                self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                PetFinderBreeds[self.breed!.BreedName] = self.pets
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    */
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        var proceed = true
        if identifier == "felineFinderDetail" {
            let indexPath = tableView.indexPathForSelectedRow;
            let currentCell = tableView.cellForRow(at: indexPath!)! as! PetFinderCell;
            if currentCell.CatNameLabel.text == "More..."  || currentCell.CatNameLabel.text == "Loading please wait..." || currentCell.CatNameLabel.text == "There is no data." {
                proceed = false
            }
        }
        return proceed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue=\(segue.identifier)")
        if segue.identifier == "searchOptions" {
            (segue.destination as! PetFinderFindViewController).breed = breed
        }
        else if segue.identifier == "BreedStats" {
            (segue.destination as! BreedStatsViewController).whichSeque = "BreedList"
            let b = self.breed as Breed?
            (segue.destination as! BreedStatsViewController).breed = b!
        }
        else if (segue.identifier == "showDetail") {
            let b = self.breed as Breed?
            (segue.destination as! DetailViewController).breed = b!
        }
        else if segue.identifier == "felineFinderDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
                (segue.destination as! PetFinderViewDetailController).pet = petData
                (segue.destination as! PetFinderViewDetailController).petID = petData.petID
                (segue.destination as! PetFinderViewDetailController).petName = petData.name
                (segue.destination as! PetFinderViewDetailController).breedName = breed!.BreedName
            }
        }
    }
}

