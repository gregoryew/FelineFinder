//
//  MapViewController.swift
//  Purrfect4U
//
//  Created by Gregory Williams on 6/21/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import AddressBook

class MapViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    var locationManager: CLLocationManager!
    
    var i: Int = 0
    
    var Breeders: BreedersList = BreedersList()
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0)
    
    @IBOutlet weak var mapView2: MKMapView!
    @IBOutlet weak var breederPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.breederPicker.dataSource = self
        self.breederPicker.delegate = self
        
        mapView2.delegate = self
        
        self.navigationItem.title = "\(breed.BreedName) Breeders"
        
    }
    
    func parseStreetAddress(s: String) -> NSString {
        var sa: String = s.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        sa = sa.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        sa = sa.uppercaseString
        var s2 = sa as NSString
        s2 = s2.substringWithRange(NSRange(location: 0, length: 5))
        return s2
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        let lat: Double = location.coordinate.latitude
        let long: Double = location.coordinate.longitude
        
        if (Breeders.count() == 0) {
            
            Breeders.getBreedersFromZipCode("", maxDistance: 10000, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, forBreedID: Int(breed.BreedID))
            
            breederPicker.reloadAllComponents()
            
            for (var i = 0; i < Breeders.count(); ++i)
            {
                var b = Breeders.getBreedersAtIndex(i)
                if b.name == "Sorry no breeders." {
                    return
                }
                var address = ""
                if b.streetAddress != "" {
                    address += "\(b.streetAddress), "
                }
                if b.city != "" {
                    address += " \(b.city), "
                }
                address += "\(b.state) \(b.zipCode)"
                
                if (b.streetAddress != "" && parseStreetAddress(b.streetAddress) != "POBOX") {
                    var geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                        if let placemark = placemarks?[0] as? CLPlacemark {
                            let breederAnnotation = BreederAnnotation(title: b.cattery,
                                locationName: address,
                                streetAddress: (b.streetAddress != ""),
                                coordinate: CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude))
                            
                            self.mapView2.addAnnotation(breederAnnotation)
                            self.showBreeder(0)
                        }
                    })
                }
                else {
                    let breederAnnotation = BreederAnnotation(title: b.cattery,
                        locationName: address,
                        streetAddress: (b.streetAddress != ""),
                        coordinate: CLLocationCoordinate2D(latitude: b.latitude, longitude: b.longitude))
                    
                    mapView2.addAnnotation(breederAnnotation)
                    
                    self.showBreeder(0)
                }
            }
            
            centerMapOnLocation(CLLocation(latitude: lat, longitude: long))

        }

        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        print("Error getting location: \(error.description)");
    }
    
    func centerMapOnLocation(location: CLLocation) {
        if mapView2.annotations.count > 0 {
            mapView2.showAnnotations(mapView2.annotations, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BreedStats" {
            (segue.destinationViewController as! BreedStatsViewController).whichSeque = "BreedList"
            let b = self.breed as Breed?
            (segue.destinationViewController as! BreedStatsViewController).breed = b!
        }
        else if (segue.identifier == "breederList") {
            let b = self.breed as Breed?
            (segue.destinationViewController as! BreedersViewController).breed = b!
        }
        else if (segue.identifier == "showDetail") {
            let b = self.breed as Breed?
            (segue.destinationViewController as! DetailViewController).breed = b!
        }
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Breeders.count();
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let breeder = Breeders.getBreedersAtIndex(row);
        return breeder.cattery
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        showBreeder(row)
    }

    func showBreeder(row: Int) {
        var breeder = Breeders.getBreedersAtIndex(row);
        for ann in mapView2.annotations {
            if ann.title == breeder.cattery {
                if let a = ann as? BreederAnnotation {
                    if mapView2.annotations.count > 0 {
                        mapView2.showAnnotations(mapView2.annotations, animated: true)
                    }
                    self.mapView2.selectAnnotation(a, animated: true)
                }
            }
        }
    }
    
    func mapView(viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? BreederAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView2.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                if (annotation.streetAddress == true && parseStreetAddress(annotation.subtitle) != "POBOX") {
                    //println("here")
                    view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView
                }
            }
            
            //view.pinColor = annotation.pinColor()
            
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let location = view.annotation as! BreederAnnotation
        
        if (location.streetAddress == true && parseStreetAddress(location.subtitle) != "POBOX")  {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMapsWithLaunchOptions(launchOptions)
        }
        else {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Sorry, I can't display driving directions because this cattery does not supply a street address."
            alert.addButtonWithTitle("Understood")
            alert.show()
        }
    }
}

class BreederAnnotation: NSObject, MKAnnotation {
    let title2: String
    let locationName: String
    let streetAddress: Bool
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, streetAddress: Bool, coordinate: CLLocationCoordinate2D) {
        self.title2 = title
        self.locationName = locationName
        self.streetAddress = streetAddress
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title2
        
        return mapItem
    }
}