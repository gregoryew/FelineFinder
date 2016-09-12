//
//  PetFinderViewDetail.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/5/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import MapKit
import Social

class PetFinderViewDetailController: UIViewController, UIWebViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var favoriteBtn: UIBarButtonItem!
    
    var loaded: Bool = false
    var petID: String?
    var petName: String?
    var pet: Pet?
    var favoriteType: DataSource = .RescueGroup
    var s: shelter?
    var breedName: String?
    var images: [UIImage] = []
    var vc: UIActivityViewController?
    var shouldLoadWeb = false
    var whichSegue = ""
    
    @IBAction func BackTapped(sender: AnyObject) {
        if whichSegue == "Favorites" {
            //performSegueWithIdentifier("Favorites", sender: nil)
            navigationController!.popViewControllerAnimated(true)
        } else {
            performSegueWithIdentifier("PetFinderList", sender: nil)
        }
    }
    
    @IBAction func favoriteTouchUp(sender: UIBarButtonItem) {
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            Favorites.removeFavorite(petID!, dataSource: favoriteType)
            favoriteBtn.image = UIImage(named: "Like")
        }
        else {
            let urlString = pet!.getImage(1, size: "pnt")
            Favorites.addFavorite(petID!, f: Favorite(id: petID!, n: pet!.name, i: urlString, b: breedName!, d: favoriteType, s: ""))
            favoriteBtn.image = UIImage(named: "LikeFilled")
        }
    }
    
    @IBAction func unwindToPetFinderDetail(sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.favoriteType = .RescueGroup
        self.navigationController?.setToolbarHidden(false, animated:true)
        //if timer != nil {timer!.invalidate()}
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Webview fail with error \(error)");
    }
    
    var emailAddress: [String] = [String]()
    
    func getDrivingDirections(latitude lat: Double, longitude lng: Double, name n: String) {
        if CMMapLauncher.isMapAppInstalled(CMMapApp.AppleMaps)
        {
            let shelter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng);
            let CCMShelter: CMMapPoint = CMMapPoint(coordinate: shelter)
            CCMShelter.name = n
            CMMapLauncher.launchMapApp(CMMapApp.AppleMaps, forDirectionsTo: CCMShelter)
        }
    }
    
    func parseStreetAddress(s: String) -> NSString {
        var sa: String = s.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        sa = sa.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        sa = sa.uppercaseString
        var s2 = sa as NSString
        s2 = s2.substringWithRange(NSRange(location: 0, length: 5))
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
    
    func loadImage(imgURL: String) {
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string: imgURL)!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                self.images.append(UIImage(data: data!)!)
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        })
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var errors = 0
        var imageCache: [UIImage] = []
        var r: Bool = false
        let u: String = request.URL!.relativeString!
        if (u.hasPrefix("mailto:")) {
            let index1 = u.startIndex.advancedBy(7)
            let email: String = u.substringFromIndex(index1)
            emailAddress = [String]()
            emailAddress.append(email)
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            r = false
        }
        else if (u.hasSuffix("launchLocation")) {
            loadCoordinate(sh: s!)
            r = false
        }
        else if (u.hasSuffix("LikeCat")) {
            //webView.stringByEvaluatingJavaScriptFromString("")
            r = true
        }
        else if (u.hasSuffix("Pictures")) {
            self.performSegueWithIdentifier("Pictures", sender: nil)
        }
        else if (u.hasSuffix("Video")) {
            self.performSegueWithIdentifier("ShowYouTubeVideo", sender: nil)
        }
        else if (u.hasSuffix("Share")) {
                let imgs: [String] = pet!.getAllImagesOfACertainSize("pn")
                imageCache.removeAll()
                var address: String = ""
                if s!.address1 != "" {
                    address += "\(s!.address1)"
                }
                if s!.address2 != "" && address != "" {
                    address += "\r\n\(s!.address2)"
                } else {
                    address += s!.address2
                }
                if (s!.city != "" || s!.state != "" || s!.zipCode != "") && address != ""  {
                    address += "\r\n\(s!.city), \(s!.state) \(s!.zipCode)"
                } else {
                    address += "\(s!.city), \(s!.state) \(s!.zipCode)"
                }
                if (address != "") {
                    address += "\r\n\r\nAddress:\r\n\(s!.name)\r\n\(address)"
                }
                for url in imgs {
                    let imgURL = NSURL(string: url)
                    let request: NSURLRequest = NSURLRequest(URL: imgURL!)
                    let mainQueue = NSOperationQueue.mainQueue()
                    NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                        if error == nil {
                            // Convert the downloaded data in to a UIImage object
                            let image = UIImage(data: data!)
                            // Update the cell
                            imageCache.append(image!)
                            if imageCache.count + errors == imgs.count {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.vc = UIActivityViewController(activityItems: imageCache + ["About \(self.pet!.name)\r\n\(self.pet!.description) \(address) \r\n\r\nContact Info\r\n\(self.s!.email)\r\n\(self.s!.phone)" ], applicationActivities: [])
                                    //presentViewController(vc!, animated: true, completion: nil)
                                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
                                        self.presentViewController(self.vc!, animated: true, completion: nil)
                                        self.loaded = false
                                    }
                                    else {
                                        let popup: UIPopoverController = UIPopoverController(contentViewController: self.vc!)
                                        popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                                        self.loaded = false
                                    }
                                    self.loaded = true
                                })
                            }
                        } else {
                            errors += 1
                        }
                    })
                }
        }
        else if (u.hasPrefix("tel:")) {
            
            let p: String = s!.phone
            
            var u: NSURL?
            
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
            //println("phone=\(str)")
            if let url = NSURL(string: str) {
                u = url
            } else {
                return true
            }
            let actionSheetController: UIAlertController = UIAlertController(title: "Call \(s!.name)?", message: "Do you want to call \(s!.name) at \(s!.phone) now?", preferredStyle: .ActionSheet)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            //Create and add first option action
            let callAction: UIAlertAction = UIAlertAction(title: "Call", style: .Default) { action -> Void in
                UIApplication.sharedApplication().openURL(u!)
            }
            actionSheetController.addAction(callAction)
            
            //We need to provide a popover sourceView when using it on iPad
            actionSheetController.popoverPresentationController?.sourceView = webView.superview;
            
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
        //else if navigationType == UIWebViewNavigationType.LinkClicked {
        //    UIApplication.sharedApplication().openURL(request.URL!)
        //    r = false
        //}
        else {
            if shouldLoadWeb == true {
                r = true
                shouldLoadWeb = false
            } else {
                let actionSheetController: UIAlertController = UIAlertController(title: "Copy URL to Clipboard?", message: "Sorry but I cannot go to outside websites.  Should I copy the URL to your clipboard and then you can paste it in a web browser?", preferredStyle: .ActionSheet)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .Cancel) { action -> Void in
                    //Just dismiss the action sheet
                }
                actionSheetController.addAction(cancelAction)
                //Create and add first option action
                let callAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                    UIPasteboard.generalPasteboard().string = (request.URL!.absoluteString ?? "")
                }
                actionSheetController.addAction(callAction)
                
                //We need to provide a popover sourceView when using it on iPad
                actionSheetController.popoverPresentationController?.sourceView = webView.superview;
                
                //Present the AlertController
                self.presentViewController(actionSheetController, animated: true, completion: nil)

                r = false
            }

    }
        return r
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    
        mailComposerVC.setToRecipients(emailAddress)
        //mailComposerVC.setSubject("Sending you an in-app e-mail...")
        //mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
    
        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func webViewDidStartLoad(webView: UIWebView) {
        print("Webview started Loading")
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        print("Webview did finish load")
    }
    
    func configureView(p: Pet, s: shelter) -> String {
        var contact: String
        shouldLoadWeb = true
        var b: String = ""
        for b2 in p.breeds {
            if (b == "") {
                b = "\(b2)"
            }
            else {
                b = "\(b) & \(b2)"
            }
        }
        var o: String = ""
        for o2 in p.options {
            if (o == "") {
                o = "\(o2)"
            }
            else {
                o = "\(o) • \(o2)"
            }
        }
        var imagesHTML: String = ""
        var imageHTML: String = ""
        for img2 in p.media {
            if img2.size == "x" {
                imageHTML = "<img src=\"\(img2.URL)\" width=300 style=\"margin:0px auto;display:block\"/>"
                loadImage(img2.URL)
                if imagesHTML == "" {
                    imagesHTML = "\(imageHTML)"
                }
                else {
                    imagesHTML = "\(imagesHTML)<br/>\(imageHTML)"
                }
            }
        }
        
        contact = "\(s.name) • \(s.city), \(s.state)"
        
        var html: String = ""
        html = "\(html)<tr><td><b>Address:</b></td></tr>"
        if (s.name != "") {
            html = "\(html)<tr><td>\(s.name)</td></tr>"
        }
        if (s.address1 != "") {
            html = "\(html)<tr><td>\(s.address1)</td></tr>"
        }
        if (s.address2 != "") {
            html = "\(html)<tr><td>\(s.address2)</td></tr>"
        }
        var c: String = ""
        var st: String = ""
        var z: String = ""
        if (s.city != "") {
            c = s.city
        }
        if (s.state != "") {
            st = s.state
        }
        if (s.zipCode != "") {
            z = s.zipCode
        }
        if (z != "" || c != "" || st != "") {
            html = "\(html)<tr><td>\(c), \(st) \(z)</td></tr>"
        }
        html = "\(html)<tr><td><a href=\"launchLocation\">Driving Directions</a></td></tr>"
        html = "\(html)<tr><td>&nbsp;</td></tr><tr><td><b>Contact Info</b></td></tr>"
        if (s.email != "") {
            if (s.phone != "") {
                html = "\(html)<tr><td>&nbsp;</td></tr>"
            }
            html = "\(html)<tr><td><a href=\"mailto:\(s.email)\">E-Mail: \(s.email)</a></td></tr>"
        }
        if (s.phone != "") {
            if (s.email != "") {
                html = "\(html)<tr><td>&nbsp;</td></tr>"
            }
            html = "\(html)<tr><td><a href=\"tel:\(s.phone)\">Call: \(s.phone)</a></td></tr>"
            html = "\(html)<tr><td>&nbsp;</td></tr>"
        }
        html = "\(html)<tr><td><a href=\"Share\">Share</a></td></tr>"
        
        var headerContent: String = "<tr><td style=\"background-color:#8AC007; text-color:white\">Basics:</td><td>\(b) • \(p.age) • \(p.sex) • \(p.size)</td></tr>"
        headerContent = "\(headerContent)<tr><td style=\"background-color:#8AC007; text-color:white\">Shelter:</td><td>\(contact)</td></tr>"
        headerContent = "\(headerContent)<tr><td style=\"background-color:#8AC007; text-color:white\">Options:</td><td>\(o)</td></tr>"
        
        var url = ""
        var w = 0
        var pictures = [String]()
        var rowspan = 0
        var tableWidth = 0
        if UIDevice().type == Model.iPhone5 || UIDevice().type == Model.iPhone5C || UIDevice().type == Model.iPhone5S {
            pictures = p.getAllImagesOfACertainSize("pn")
            w = 100
            rowspan = 2
            tableWidth = 300
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            pictures = p.getAllImagesOfACertainSize("pn")
            w = 150
            rowspan = 2
            tableWidth = 360
        } else {
            pictures = p.getAllImagesOfACertainSize("x")
            w = 300
            rowspan = 2
            tableWidth = 700
        }

        if pictures.count > 0 {
            url = pictures[0]
        } else {
            url = ""
        }
        
        var picture = ""
        if p.media.count == 0 {
            picture = ""
        } else {
            picture = "<a href=\"Pictures\"><img src=\"\(url)\" style=\"box-shadow:10px 10px 5px black\" width=\"\(String(w))\"><h1><b><input type=\"button\" value=\"Pictures...\"></a></b></h1>"
        }
        
        var videos = ""
        if p.videos.count > 0 {
            videos = "<td width=\"83\"><a href=\"Video\"><h1><img src=\"youtube.png\" width=\"40\"/></a></td>"
        }
        
        var born = ""
        if p.birthdate != "" {
            born = "<h1><Born \(p.birthdate)/h1>"
        }
        
        let htmlString = "<!DOCTYPE html><html><header><style>h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px;} h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} a { color: #abcde1} a.visited, a.hover {color: #1abcde;} </style></header><body><table width=\"\(tableWidth)\"><tr><td width=\"100%\"><table width=\"100%\"><tr><td><h3><b>Meet \(p.name)</b></h3>\(born)<h1>\(p.status)</h1><h2>\(c), \(st)</h2></td><td rowspan=\"\(rowspan)\" valign=\"middle\" align=\"right\">\(picture)</td></tr><tr><td valign=\"bottsom\"><b><h2>GENERAL INFORMATION</h2></b></td></tr><tr><td colspan=\"2\"><h1>\(b)</br>\(p.age) • \(p.sex) • \(p.size)</br>\(o)</h1></td></tr></table></td></tr><tr><td><h2>CONTACT</h2><h1>\(s.name)</br>\(s.address1)</br>\(c), \(s.state) \(s.zipCode)</h1><center><table><tr><td width = \"83\"><a href=\"launchLocation\"><IMG SRC=\"directions.png\" width=\"40\"></a></td><td width=\"83\"><a href=\"tel:\(s.phone)\"><IMG SRC=\"phone.png\" width=\"40\"></a></td><td width=\"83\"><a href=\"mailto:\(s.email)\"><IMG SRC=\"email.png\" width=\"40\"></a></td><td width=\"83\"><a href=\"Share\"><IMG SRC=\"share.png\" width=\"40\"></a></td>\(videos)</tr></table></h1></center></td></tr><tr><td><h2>DESCRIPTION</h2><h1><p style=\"word-wrap: break-word;\">\(p.description)</p></h1></td></tr><tr><td></td></tr><tr><td><h2>DISCLAIMER</h2><h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.</h4></td></tr></table></body></html>"
        return htmlString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        webView.dataDetectorTypes = UIDataDetectorTypes.Link
    }
    
    var currentIndex = 0
    var timer: NSTimer?
    
    func removeViewWithTag(tag: Int) {
        if let viewWithTag = view.viewWithTag(tag) {
            print("Tag 100")
            viewWithTag.removeFromSuperview()
        }
        else {
            print("tag not found")
        }
    }
    
    func blurImage(image2: UIImage) {
        let imageView = UIImageView(image: image2)
        removeViewWithTag(998)
        removeViewWithTag(999)
        imageView.frame = view.bounds
        imageView.contentMode = .ScaleToFill
        imageView.tag = 998
    
        view.addSubview(imageView)
    
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        blurredEffectView.tag = 999
        view.addSubview(blurredEffectView)
    
        self.view.sendSubviewToBack(blurredEffectView)
        self.view.sendSubviewToBack(imageView)
    /*
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: #selector(PetFinderViewDetailController.getImage), userInfo: nil, repeats: true)
        }
    */
    }
    
    func getImage() {
        var url = ""
        if imageURLs.count == 0 {
            dispatch_async(dispatch_get_main_queue(), {
            self.blurImage(UIImage(named: "Devon Rex")!)
                })
            return
        } else {
            if currentIndex == imageURLs.count - 1 { currentIndex = 0} else { currentIndex += 1}
            url = imageURLs[currentIndex]
        }
        
        let imgURL = NSURL(string: url)
        print(url)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data!)
                // Update the cell
                dispatch_async(dispatch_get_main_queue(), {
                    self.blurImage(image!)
                })
            }
        })
    }
    
    var imageURLs:[String] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated:true)
        
        if (!Favorites.loaded) {Favorites.LoadFavorites()}
        
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            favoriteBtn.image = UIImage(named: "LikeFilled")
        }
        else {
            favoriteBtn.image = UIImage(named: "Like")
        }
        
        self.title = "\(petName!)"
        
        let pl: PetList = (favoriteType == .PetFinder ? PetFinderPetList() : RescuePetList())
        let sl: ShelterList = (favoriteType == .PetFinder ? PetFinderShelters : Shelters)
        
        pl.loadSinglePet(petID!, completion: { (pet) -> Void in
            sl.loadSingleShelter(pet.shelterID, completion: { (shelter) -> Void in
                let path = NSBundle.mainBundle().bundlePath;
                let sBaseURL = NSURL.fileURLWithPath(path);
                self.s = shelter
                self.pet = pet
                let htmlString = self.configureView(pet, s: shelter);
                self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
                self.imageURLs = (self.pet?.getAllImagesOfACertainSize("x"))!
                self.getImage()
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "Pictures") {
            (segue.destinationViewController as! PetFinderPicturesViewController).breedName = ""
            (segue.destinationViewController as! PetFinderPicturesViewController).petData = pet!
            
        } else if (segue.identifier == "ShowYouTubeVideo") {
            (segue.destinationViewController as! YouTubeViewController).youtubeid = pet!.videos[0].videoID
        }
    }
}