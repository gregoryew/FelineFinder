//
//  Breeders.swift
//  Purrfect4U
//
//  Created by Gregory Williams on 6/19/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import CoreLocation

class BreedersViewController: UITableViewController, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    var i: Int = 0
    
    var Breeders: BreedersList = BreedersList()
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\(breed.BreedName) Breeders"
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let lat: Double = location.coordinate.latitude
        let long: Double = location.coordinate.longitude
        
        if (Breeders.count() == 0) {
            Breeders.getBreedersFromZipCode("", maxDistance: 10000, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, forBreedID: Int(breed.BreedID))
            self.tableView.reloadData()
        }
        //println("didUpdateLocations \(++i)")
        locationManager.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //println("Error getting location: \(error.description)");
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            (segue.destinationViewController as! DetailViewController).breed = breed
        }
        else if (segue.identifier == "breedStats")
        {
            (segue.destinationViewController as! BreedStatsViewController).breed = breed
        }
        /*
        else if (segue.identifier == "BreederMap")
        {
            (segue.destinationViewController as! MapViewController).breed = breed
        }
        */
        else if (segue.identifier == "petFinder") {
            let b = self.breed as Breed?
            (segue.destinationViewController as! PetFinderViewController).breed = b!
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Breeders.count()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)->UITableViewCell{
        let i = indexPath.row
        let b = Breeders.getBreedersAtIndex(i)
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BreederCell
        cell.BreederName!.text = b.cattery
        if (b.name != "Sorry no breeders.") {
            cell.Distance.text = "approx. \(b.distance) miles State: \(b.state)"} else {
            cell.Distance.text = ""
        }
        
        cell.EmailBtn.hidden = b.email.isEmpty
        cell.WebBtn.hidden = b.webSite.isEmpty
        cell.CallBtn.hidden = b.phone.isEmpty

        cell.phone = b.phone
        cell.email = b.email
        cell.website = b.webSite
        cell.tvc = self
        
        return cell
    }
    
    var emails: [String] = []
    
    func sendEmail(to: String) {
        emails = []
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for var i = 0; i < indexPaths.count; ++i {
                var thisPath = (indexPaths as! [NSIndexPath])[i]
                var cell = tableView.cellForRowAtIndexPath(thisPath) as! BreederCell
                emails.append(cell.email)
            }
        }
        else {
            emails.append(to)
        }
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(emails)
        //mailComposerVC.setSubject("Sending you an in-app e-mail...")
        //mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}


