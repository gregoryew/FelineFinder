//
//  FelineFinderDetailViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/14/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import MapKit
import Social
import TransitionTreasury
import TransitionAnimation

class FelineFinderDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, NavgationTransitionable {
    
    var petID: String?
    var petName: String?
    var pet: Pet?
    var favoriteType: DataSource = .RescueGroup
    var s: shelter?
    var breedName: String?
    var images: [UIImage] = []
    var vc: UIActivityViewController?
    var whichSegue = ""
    var currentIndex = 0
    
    let options: [String] = ["Domestic Short Hair", "Young * Female * Small", "Has Claws", "Spayed/Neutereed", "Up-to-date"]
    
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var Picture: UIImageView!
    @IBOutlet weak var OptionsTableView: UITableView!
    @IBOutlet weak var DirectionsButton: UIButton!
    @IBOutlet weak var PhoneButton: UIButton!
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var EmailButton: UIButton!
    @IBOutlet weak var YouTubeVideo: UIButton!
    @IBOutlet weak var DescriptionTextView: UITextView!
    @IBOutlet weak var FavoriteBtn: UIBarButtonItem!
    @IBOutlet weak var BackBtn: UIBarButtonItem!

    var tr_pushTransition: TRNavgationTransitionDelegate?
    

    
    @IBAction func FavoriteTapped(_ sender: AnyObject) {
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            Favorites.removeFavorite(petID!, dataSource: favoriteType)
            FavoriteBtn.image = UIImage(named: "Like")
        }
        else {
            let urlString = pet!.getImage(1, size: "pnt")
            Favorites.addFavorite(petID!, f: Favorite(id: petID!, n: pet!.name, i: urlString, b: breedName!, d: favoriteType, s: ""))
            FavoriteBtn.image = UIImage(named: "LikeFilled")
        }
    }
    
    func getDrivingDirections(latitude lat: Double, longitude lng: Double, name n: String) {
        if CMMapLauncher.isMapAppInstalled(CMMapApp.appleMaps)
        {
            let shelter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng);
            let CCMShelter: CMMapPoint = CMMapPoint(coordinate: shelter)
            CCMShelter.name = n
            CMMapLauncher.launch(CMMapApp.appleMaps, forDirectionsTo: CCMShelter)
        }
    }
    
    func parseStreetAddress(_ s: String) -> NSString {
        var sa: String = s.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
        sa = sa.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        sa = sa.uppercased()
        var s2 = sa as NSString
        s2 = s2.substring(with: NSRange(location: 0, length: 5)) as NSString
        return s2
    }
    
    func loadCoordinate(sh s: shelter) {
        var address = ""
        if s.address1 != "" {
            address += "\(s.address1) "
        }
        if s.address2 != "" {
            address += "\(s.address2) "
        }
        address += "\n"
        if s.city != "" {
            address += " \(s.city), "
        }
        address += "\(s.state) \(s.zipCode)"
        
        if (s.address1 != "" && parseStreetAddress(s.address1) != "POBOX") {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address,completionHandler: {(placemarks, error) -> Void in
                if let placemark = placemarks?[0] as CLPlacemark! {
                    //println("address = \(address) corridinate = (\(placemark.location!.coordinate.latitude), \(placemark.location!.coordinate.longitude))")
                    self.getDrivingDirections(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude, name: s.name)
                }
                else {
                    self.getDrivingDirections(latitude: s.latitude, longitude: s.longitude, name: s.name)
                }
            })
        }
        else {
            getDrivingDirections(latitude: s.latitude, longitude: s.longitude, name: s.name)
        }
    }
    
    @IBAction func DirectionsTapped(_ sender: AnyObject) {
        loadCoordinate(sh: s!)
    }
    
    @IBAction func PhoneTapped(_ sender: AnyObject) {
        let p: String = s!.phone
        
        var u: URL?
        
        var str: String = ""
        var num: Int = 0
        //let b: Bool = false
        var tot: Int = 0
        for c1 in p.characters {
            if c1 >= "0" && c1 <= "9" {
                num += 1
                if num == 1 {
                    if c1 == "1" {
                        tot = 11
                    }
                    else {
                        tot = 10
                    }
                }
                str = "\(str)\(c1)"
                if num == tot {
                    break
                }
            }
        }
        if tot == 10 {
            str = "1\(str)"
        }
        str = "tel:\(str)"
        
        u = nil
        
        if let url = URL(string: str) {
            u = url
        }
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Call \(s!.name)?", message: "Do you want to call \(s!.name) at \(s!.phone) now?", preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let callAction: UIAlertAction = UIAlertAction(title: "Call", style: .default) { action -> Void in
            UIApplication.shared.openURL(u!)
        }
        actionSheetController.addAction(callAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = view.superview;
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func EmailTapped(_ sender: AnyObject) {
        let email = s!.email
        //let index1 = u.startIndex.advancedBy(7)
        //let email: String = u.substringFromIndex(u)
        emailAddress = [String]()
        emailAddress.append(email)
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        Utilities.displayAlert("Could Not Send Email", errorMessage: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(emailAddress)
        //mailComposerVC.setSubject("Sending you an in-app e-mail...")
        //mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    @IBAction func ShareTapped(_ sender: AnyObject) {
    }
    
    @IBAction func YouTubeTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ShowYouTubeVideo", sender: nil)
    }
    
    @IBAction func PicturesTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "Pictures", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OptionsTableView.delegate = self
        OptionsTableView.dataSource = self
        
        blurImage(UIImage(named: "Devon Rex")!)
        
        Picture.layer.shadowColor = UIColor.black.cgColor
        Picture.layer.shadowOpacity = 1
        Picture.layer.shadowOffset = CGSize(width: 5, height: 5)
        Picture.layer.shadowRadius = 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OptionsTableViewCell
        cell.optionTextLabel.text = options[indexPath.row]
        return cell
    }
    
    func removeViewWithTag(_ tag: Int) {
        if let viewWithTag = view.viewWithTag(tag) {
            print("Tag 100")
            viewWithTag.removeFromSuperview()
        }
        else {
            print("tag not found")
        }
    }
    
    func blurImage(_ image2: UIImage) {
        let imageView = UIImageView(image: image2)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleToFill
        
        view.addSubview(imageView)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        
        self.view.sendSubview(toBack: blurredEffectView)
        self.view.sendSubview(toBack: imageView)
    }
    
    func getImage() {
        var url = ""
        if imageURLs.count == 0 {
            DispatchQueue.main.async(execute: {
                self.blurImage(UIImage(named: "Devon Rex")!)
            })
            return
        } else {
            if currentIndex == imageURLs.count - 1 { currentIndex = 0} else { currentIndex += 1}
            url = imageURLs[currentIndex]
        }
        
        let imgURL = URL(string: url)
        print(url)
        let request: URLRequest = URLRequest(url: imgURL!)
        //let mainQueue = NSOperationQueue.mainQueue()
        //NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
        _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data!)
                // Update the cell
                DispatchQueue.main.async(execute: {
                    self.blurImage(image!)
                })
            }
            }).resume()
    }
    
    @IBAction func unwindToFelineFinderDetail(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.favoriteType = .RescueGroup
        self.navigationController?.setToolbarHidden(false, animated:false)
    }
    
    var emailAddress: [String] = [String]()
    
    func loadImage(_ imgURL: String) {
        let request: URLRequest = URLRequest(url: URL(string: imgURL)!)
        //let mainQueue = NSOperationQueue.mainQueue()
        //NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
        _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if error == nil {
                self.images.append(UIImage(data: data!)!)
            } else {
                print("Error: \(error!.localizedDescription)")
            }
            }).resume()
    }
    
    var imageURLs:[String] = []
    
    func fillViewWithData() {
        self.HeaderLabel.text = "Meet \(self.pet!.name)\r\n\(self.pet!.status)\r\n\r\n\(self.s!.name)\r\n\(self.s!.address1)\r\n\(self.s!.city) \(self.s!.state) \(self.s!.zipCode)\r\nGENERAL INFO"
        self.DescriptionTextView.text = self.pet!.description
        
        self.imageURLs = (self.pet?.getAllImagesOfACertainSize("x"))!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated:false)
        
        if (!Favorites.loaded) {Favorites.LoadFavorites()}
        
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            FavoriteBtn.image = UIImage(named: "LikeFilled")
        }
        else {
            FavoriteBtn.image = UIImage(named: "Like")
        }
        
        self.title = "\(petName!)"
        
        let pl: PetList = (favoriteType == .PetFinder ? PetFinderPetList() : RescuePetList())
        let sl: ShelterList = (favoriteType == .PetFinder ? PetFinderShelters : Shelters)
        
        pl.loadSinglePet(petID!, completion: { (pet) -> Void in
            sl.loadSingleShelter(pet.shelterID, completion: { (shelter) -> Void in
                self.s = shelter
                self.pet = pet
                DispatchQueue.main.async(execute: {
                    self.fillViewWithData()
                })
            })
        })
    }

    
    
    
    
}
