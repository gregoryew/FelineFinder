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
import FaveButton
import TransitionTreasury
import TransitionAnimation

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}

class PetFinderViewDetailController: UIViewController, UIWebViewDelegate, MFMailComposeViewControllerDelegate, FaveButtonDelegate, NavgationTransitionable {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var favoriteBtn: FaveButton?
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
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
    
    @IBAction func BackTapped(_ sender: AnyObject) {
        if whichSegue == "Favorites" {
            performSegue(withIdentifier: "Favorites", sender: nil)
            //navigationController!.popViewControllerAnimated(true)
        } else {
            performSegue(withIdentifier: "PetFinderList", sender: nil)
        }
    }
    
    let colors = [
        DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
        DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
        DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
        DotColors(first: color(0xE9A966), second: color(0xF8C852)),
        DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
    ]
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool){
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            Favorites.removeFavorite(petID!, dataSource: favoriteType)
        } else {
            let urlString = pet!.getImage(1, size: "pnt")
            Favorites.addFavorite(petID!, f: Favorite(id: petID!, n: pet!.name, i: urlString, b: breedName!, d: favoriteType, s: ""))
        }
    }
    
    /*
    @IBAction func favoriteTouchUp(_ sender: UIBarButtonItem) {
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
    */
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if faveButton === favoriteBtn{
            return colors
        }
        return nil
    }
    
    @IBAction func unwindToPetFinderDetail(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.favoriteType = .RescueGroup
        self.navigationController?.setToolbarHidden(false, animated:false)
        //if timer != nil {timer!.invalidate()}
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Webview fail with error \(error)");
    }
    
    var emailAddress: [String] = [String]()
    
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
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var errors = 0
        var imageCache: [UIImage] = []
        var r: Bool = false
        let u: String = request.url!.relativeString
        if (u.hasPrefix("mailto:")) {
            let index1 = u.characters.index(u.startIndex, offsetBy: 7)
            let email: String = u.substring(from: index1)
            emailAddress = [String]()
            emailAddress.append(email)
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
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
            self.performSegue(withIdentifier: "Pictures", sender: nil)
        }
        else if (u.hasSuffix("Video")) {
            self.performSegue(withIdentifier: "ShowYouTubeVideo", sender: nil)
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
                    let imgURL = URL(string: url)
                    let request: URLRequest = URLRequest(url: imgURL!)
                    _ = OperationQueue.main
                    //NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                    _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                        if error == nil {
                            // Convert the downloaded data in to a UIImage object
                            let image = UIImage(data: data!)
                            // Update the cell
                            imageCache.append(image!)
                            if imageCache.count + errors == imgs.count {
                                DispatchQueue.main.async(execute: {
                                    self.vc = UIActivityViewController(activityItems: imageCache + ["About \(self.pet!.name)\r\n\(self.pet!.description) \(address) \r\n\r\nContact Info\r\n\(self.s!.email)\r\n\(self.s!.phone)" ], applicationActivities: [])
                                    //presentViewController(vc!, animated: true, completion: nil)
                                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                                        self.present(self.vc!, animated: true, completion: nil)
                                        self.loaded = false
                                    }
                                    else {
                                        //let popup: UIPopoverController = UIPopoverController(contentViewController: self.vc!)
                                        //popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                                        self.loaded = false
                                    }
                                    self.loaded = true
                                })
                            }
                        } else {
                            errors += 1
                        }
                    }).resume()
                }
        }
        else if (u.hasPrefix("tel:")) {
            
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
            //println("phone=\(str)")
            if let url = URL(string: str) {
                u = url
            } else {
                return true
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
            actionSheetController.popoverPresentationController?.sourceView = webView.superview;
            
            //Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
        //else if navigationType == UIWebViewNavigationType.LinkClicked {
        //    UIApplication.sharedApplication().openURL(request.URL!)
        //    r = false
        //}
        else {
            if shouldLoadWeb == true {
                r = true
                shouldLoadWeb = false
            } else if navigationType == UIWebViewNavigationType.linkClicked{
                let actionSheetController: UIAlertController = UIAlertController(title: "Copy URL to Clipboard?", message: "Sorry but I cannot go to outside websites.  Should I copy the URL to your clipboard and then you can paste it in a web browser?", preferredStyle: .actionSheet)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
                    //Just dismiss the action sheet
                }
                actionSheetController.addAction(cancelAction)
                //Create and add first option action
                let callAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                    UIPasteboard.general.string = (request.url!.absoluteString )
                }
                actionSheetController.addAction(callAction)
                
                //We need to provide a popover sourceView when using it on iPad
                actionSheetController.popoverPresentationController?.sourceView = webView.superview;
                
                //Present the AlertController
                self.present(actionSheetController, animated: true, completion: nil)

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
        Utilities.displayAlert("Could Not Send Email", errorMessage: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Webview started Loading")
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "window.scroll(0,0)")
        print("Webview did finish loadss")
    }
    
    func configureView(_ p: Pet, s: shelter) -> String {
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
            if o2 == "" {
                continue
            }
            if (o == "") {
                o = "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">\(o2)</br>"
            }
            else {
                o = "\(o) <IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">\(o2)</br>"
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
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
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
        
        var options = ""
        if b != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">\(b)</br>"
        }
        if p.age != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">\(p.age)</br>"
        }
        if p.sex != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">\(p.sex)</br>"
        }
        if p.size != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">\(p.size)</br>"
        }
        
        //320px
        var width: String?
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = "640px"
        } else {
            width = "320px"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let d = dateFormatter.string(from: p.lastUpdated)
        
        let htmlString = "<!DOCTYPE html><html><header><style>h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px;} h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} a { color: #abcde1} a.visited, a.hover {color: #1abcde;} </style></header><body><center><table width=\"\(tableWidth)\"><tr><td width=\"100%\"><table width=\"100%\"><tr><td><h3><b>Meet \(p.name)</b></h3><h2>\(c), \(st)</h2><h1>\(born)</h1><h1>\(p.status)</h1><h1>Updated: \(d)</h1></td><td rowspan=\"\(rowspan)\" valign=\"middle\" align=\"right\">\(picture)</td></tr></table><b><center><h2>GENERAL INFORMATION</h2></center></b><h1>\(options)\(o)</br></h1><table><tr><td><center><h2>CONTACT</h2></center><h1>\(s.name)</br>\(s.address1)</br>\(c), \(s.state) \(s.zipCode)</h1><center><table><tr><td width = \"83\"><a href=\"launchLocation\"><IMG SRC=\"directions.png\" width=\"40\"></a></td><td width=\"83\"><a href=\"tel:\(s.phone)\"><IMG SRC=\"phone.png\" width=\"40\"></a></td><td width=\"83\"><a href=\"mailto:\(s.email)\"><IMG SRC=\"email.png\" width=\"40\"></a></td><td width=\"83\"><a href=\"Share\"><IMG SRC=\"share.png\" width=\"40\"></a></td>\(videos)</tr></table></h1></center></td></tr><tr><td><h2><center>DESCRIPTION</center></h2><div style='overflow-y:visible; overflow-x:scroll; width:\(width!)'><h1><p style=\"word-wrap: break-word;\">\(p.description)</p></h1></div></td></tr><tr><td></td></tr><tr><td><h2><center>DISCLAIMER</center></h2><h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.</h4></td></tr></table></center></body></html>"
        return htmlString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(webView.frame)")
        webView.delegate = self
        webView.dataDetectorTypes = UIDataDetectorTypes.link
        favoriteBtn?.delegate = self
    }
    
    var currentIndex = 0
    var timer: Timer?
    
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
        removeViewWithTag(998)
        removeViewWithTag(999)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleToFill
        imageView.tag = 998
    
        view.addSubview(imageView)
    
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        blurredEffectView.tag = 999
        view.addSubview(blurredEffectView)
    
        self.view.sendSubview(toBack: blurredEffectView)
        self.view.sendSubview(toBack: imageView)
    /*
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: #selector(PetFinderViewDetailController.getImage), userInfo: nil, repeats: true)
        }
    */
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
    
    var imageURLs:[String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated:false)
        
        if (!Favorites.loaded) {Favorites.LoadFavorites()}
        
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            favoriteBtn?.isSelected = true
        } else {
            favoriteBtn?.isSelected = false
        }
        
        self.title = "\(petName!)"
        
        /*
        let pl: PetList = (favoriteType == .PetFinder ? PetFinderPetList() : RescuePetList())
        let sl: ShelterList = (favoriteType == .PetFinder ? PetFinderShelters : Shelters)
        */
        
        let pl = RescuePetList()
        let sl = Shelters
        
        var times = 0
        
        pl.status = ""
        
        repeat {
        pl.loadSinglePet(petID!, completion: { (pet) -> Void in
            sl.loadSingleShelter(pet.shelterID, completion: { (shelter) -> Void in
                if shelter.id == "ERROR" {
                    Utilities.displayAlert("Shelter Not Found", errorMessage: "Sorry the shelter has not been found or an error occurred.  Please press the back button and try another cat or again try later.")
                }
                let path = Bundle.main.bundlePath;
                let sBaseURL = URL(fileURLWithPath: path);
                self.s = shelter
                self.pet = pet
                let htmlString = self.configureView(pet, s: shelter);
                self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
                self.imageURLs = (self.pet?.getAllImagesOfACertainSize("x"))!
                self.getImage()
            })
        })
        times += 1
        } while pl.status != "ok" && pl.status != "warning" && times < 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Pictures") {
            (segue.destination as! PetFinderPicturesViewController).breedName = ""
            (segue.destination as! PetFinderPicturesViewController).petData = pet!
            
        } else if (segue.identifier == "ShowYouTubeVideo") {
            (segue.destination as! YouTubeViewController).youtubeid = pet!.videos[0].videoID
        }
    }
}
