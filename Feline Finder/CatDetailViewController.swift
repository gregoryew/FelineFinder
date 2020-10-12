//
//  CatDetailViewController.swift
//  
//
//  Created by gregoryew1 on 6/27/17.
//
//

import Foundation
import UIKit
import MessageUI
import MapKit
import Social
import FaveButton
import WebKit

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}

var scrollPos: IndexPath?
var whichTab = 0

class CatDetailViewController: ZoomAnimationViewController, UIScrollViewDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    var observer : Any!
    
    @IBAction func catImageButton(_ sender: Any) {
        if let p = pet, let pictures = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Pictures") as? PetFinderPicturesViewController {
            pictures.petData = p
            present(pictures, animated: true, completion: nil)
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        //processFavorite()
        NotificationCenter.default.removeObserver(observer)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewToShow = storyboard.instantiateViewController(withIdentifier: "Favorites") as! MainTabFavoritesViewController
        let viewToShow2 = storyboard.instantiateViewController(withIdentifier: "MainTabAdoptableCats") as! MainTabAdoptableCats
        if presentingViewController is MainTabBarControllerViewController {
            let vc = presentingViewController as! MainTabBarControllerViewController
            var vcs = [UIViewController]()
            vcs.append(contentsOf: vc.viewControllers![0...0])
            vcs.append(viewToShow2)
            vcs.append(viewToShow)
            vcs.append(contentsOf: vc.viewControllers![3...vc.viewControllers!.count - 1])
            vc.setViewControllers(vcs, animated: false)
        }
        presentingViewController?.dismiss(animated: false) {
            if whichTab == 1 { //Favorites
                viewToShow.tableView.reloadRows(at: [scrollPos!], with: .none)
                viewToShow.tableView.scrollToRow(at: scrollPos!, at:.middle, animated: false)
            } else { //Adoptable Cats
                viewToShow2.MainTV.reloadRows(at: [scrollPos!], with: .none)
                viewToShow2.MainTV.scrollToRow(at: scrollPos!, at:.middle, animated: false)
            }
        }
    }
    
    @IBAction func picturesTapped(_ sender: Any) {
        if let p = pet, let pictures = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Pictures") as? PetFinderPicturesViewController {
            pictures.petData = p
            present(pictures, animated: true, completion: nil)
        }
    }
        
    @IBAction func directionsTapped(_ sender: Any) {
        self.loadCoordinate(sh: s!)
    }
    
    @IBAction func FavoriteTapped(_ sender: Any) {
        if favorited {
            print("NOT FAVORITED")
            favorited = false
        } else {
            favorited = true
            print("FAVORITED")
        }
    }
    
    @IBAction func callTapped(_ sender: Any) {
        let p: String = s!.phone
        
        var u: URL?
        
        var str: String = ""
        var num: Int = 0
        //let b: Bool = false
        var tot: Int = 0
        for c1 in p {
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
            return
        }
        let actionSheetController: UIAlertController = UIAlertController(title: "Call \(s!.name)?", message: "Do you want to call \(s!.name) at \(s!.phone) now?", preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let callAction: UIAlertAction = UIAlertAction(title: "Call", style: .default) { action -> Void in
            UIApplication.shared.open(u!, options: [:], completionHandler: nil)
        }
        actionSheetController.addAction(callAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = webView?.superview
        //actionSheetController.popoverPresentationController? = PhoneButton
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        var email = s?.email
        if (email?.lowercased().hasPrefix("emailto"))! {
            email = (s?.email.chopPrefix(7))!
        }
        emailAddress = [String]()
        emailAddress.append(email!)
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        var imageCache: [UIImage] = []
        var errors = 0
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
            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
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
                                //let _: UIPopoverController = UIPopoverController(contentViewController: self.vc!)
                                //popup.present(from: self.ShareButton, permittedArrowDirections: .up, animated: true)
                                //popup.presentfrom: inPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections:
                                //UIPopoverArrowDirection.Any, animated: true)
                                
                                self.vc?.modalPresentationStyle = UIModalPresentationStyle.popover
                                if let popoverController = self.vc?.popoverPresentationController {
                                    popoverController.delegate = self
                                    popoverController.sourceView = self.vc?.view
                                    popoverController.sourceRect = (self.vc?.view.bounds)!
                                    popoverController.permittedArrowDirections = UIPopoverArrowDirection.any
                                }
                                self.present(self.vc!, animated: true)
                                
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
    
    @IBAction func videoTapped(_ sender: Any) {
        if pet?.videos.count == 0 {
            return
        }
        
        let youTube = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YouTube") as! YouTubeViewController
        
        youTube.youtubeid = pet?.videos[0].videoID
        
        present(youTube, animated: false, completion: nil)
    }
    
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
    var favorited: Bool = false
    var wasFavoritedBefore: Bool = false
    
    func processFavorite() {
        self.favoriteType = .RescueGroup
        print("processFavorite")
        if wasFavoritedBefore != favorited {
            print("processing Favorite")
            wasFavoritedBefore = favorited
            if !favorited {
                print("Removing Favorite")
                Favorites.removeFavorite(petID!, dataSource: favoriteType)
            } else {
                print ("Adding Favorite")
                let urlString = pet!.getImage(1, size: "pnt")
                let bn = pet?.breeds.first
                Favorites.addFavorite(petID!, f: Favorite(petID: petID!, petName: pet!.name, imageName: urlString, breed: bn!, FavoriteDataSource: favoriteType, Status: ""))
            }
            Favorites.storeIDs()
        }
    }
    
    let colors = [
        DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
        DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
        DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
        DotColors(first: color(0xE9A966), second: color(0xF8C852)),
        DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
    ]

    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if faveButton === favoriteBtn{
            return colors
        }
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.removeViewWithTag(-1112)
        webView = nil
        processFavorite()
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
                if let placemark = placemarks?[0] as CLPlacemark? {
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
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(emailAddress)
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
        
        self.CatBreedLabel.text = b
        self.CatNameLabel.text = p.name
        
        var o: String = ""
        for o2 in p.options {
            if o2 == "" {
                continue
            }
            if (o == "") {
                o = "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(o2)</br></br>"
            }
            else {
                o = "\(o) <IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(o2)</br></br>"
            }
        }

        let largeURLs = p.getAllImagesOfACertainSize("x")
        var largeURL = ""
        if largeURLs.count > 0 {largeURL = largeURLs[0]}
        var smallURL = ""
        let smallURLs = p.getAllImagesOfACertainSize("pnt")
        if smallURLs.count > 0 {smallURL = smallURLs[0]}
        self.CatImage.sd_setImage(with:  NSURL(string: smallURL)! as URL, placeholderImage: UIImage(named: ""),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            self.CatImage.image = self.CatImage.image?.circleMasked
            DispatchQueue.main.async {
                    self.CatImage.image = self.CatImage.image?.circleMasked
            }
        })

        SDWebImageManager.shared().imageDownloader?.downloadImage(with: NSURL(string: largeURL)! as URL, options: SDWebImageDownloaderOptions.lowPriority, progress: nil, completed: {
            (image, error, cacheType, imageURL) in
            DispatchQueue.main.async {
                self.CatImage.image = image?.circleMasked
            }
        })

        DispatchQueue.main.async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let d = dateFormatter.string(from: p.lastUpdated)
            self.LocationLabel.text = "\(p.status) in \(p.location) as of \(d)"
        }
        
        LocationLabel.isUserInteractionEnabled = true
        
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
        
        var headerContent: String = "<tr><td style=\"background-color:#8AC007\">Basics:</td><td>\(b) • \(p.age) • \(p.sex) • \(p.size)</td></tr>"
        headerContent = "\(headerContent)<tr><td style=\"background-color:#8AC007\">Options:</td><td>\(o)</td></tr>"
        
        var tableWidth = 0
        if UIDevice().type == Model.iPhone5 || UIDevice().type == Model.iPhone5C || UIDevice().type == Model.iPhone5S {
            tableWidth = 300
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            tableWidth = 360
        } else {
            tableWidth = 700
        }
        
        /*
        var born = ""
        if p.birthdate != "" {
            born = "<h1>Born \(p.birthdate)</h1>"
        }
        */
        
        var options = ""
        if b != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(b)</br></br>"
        }
        if p.age != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(p.age)</br></br>"
        }
        if p.sex != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(p.sex)</br></br>"
        }
        if p.size != "" {
            options += "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(p.size)</br></br>"
        }
        
        //320px
        var width: String?
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = "640px"
        } else {
            width = "320px"
        }
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MM/dd/yyyy"
        //let d = dateFormatter.string(from: p.lastUpdated)
        
        let htmlString = "<!DOCTYPE html><html><header><style> li {margin-top: 30px;border:1px solid grey;} li:first-child {margin-top:0;} h1 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h2 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px;} h3 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h4 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} a { color: #abcde1} a.visited, a.hover {color: #1abcde;} </style></header><body><center><table width=\"\(tableWidth)\"><tr><td width=\"100%\"><table width=\"100%\"><tr><td><center><h3><b>GENERAL INFORMATION</b></h3></center><h2></td></tr></table><h1>\(options)\(o)</br></h1><table><tr><td><center><h2>CONTACT</h2></center><h1>\(s.name)</br>\(s.address1)</br>\(c), \(s.state) \(s.zipCode)</h1></td></tr><tr><td><h2><center>DESCRIPTION</center></h2><div style='overflow-y:visible; overflow-x:scroll; width:\(width!)'><h1><p style=\"word-wrap: break-word;\">\(p.description)</p></h1></div></td></tr><tr><td></td></tr><tr><td><h2><center>DISCLAIMER</center></h2><h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.</h4></td></tr></table></center></body></html>"
        return htmlString
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        observer = nc.addObserver(forName:petLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petLoaded(notification: notification)
        }
        
        favoriteBtn?.normalColor = UIColor.white
        favoriteBtn?.setNeedsDisplay()
        
        DownloadManager.loadPet(petID: petID!)
    }
    
    deinit {
        webView?.loadHTMLString("", baseURL: nil)
        webView?.stopLoading()
        //webView.delegate = nil
        webView?.removeFromSuperview()
        webView = nil
        print("deinit PetFinderViewDetailController")
    }
    
    func petLoaded(notification:Notification) -> Void {
        print("petLoaded notification")
        
        guard let userInfo = notification.userInfo,
            let pet = userInfo["pet"] as? Pet,
            let shelter = userInfo["shelter"] as? shelter else {
                print("No userInfo found in notification")
                return
        }
        
        DispatchQueue.main.async { [unowned self] in
            let path = Bundle.main.bundlePath;
            let sBaseURL = URL(fileURLWithPath: path);
            self.s = shelter
            self.pet = pet
            if self.pet?.videos.count == 0 {
                DispatchQueue.main.async(execute: {self.VideoButton.isEnabled = false})}
            if self.pet?.media.count == 0 {
                DispatchQueue.main.async(execute: {self.GalleryButton.isEnabled = false})
            }
            if shelter.email == "" {
                DispatchQueue.main.async(execute: {self.EmailButton.isEnabled = false})
            }
            let address = shelter.address1.uppercased().replacingOccurrences(of: " ", with: "")
            if address.hasPrefix("POBOX") || address.hasPrefix("P.O.") || address == "" {
                DispatchQueue.main.async(execute: {self.LocationButton.isEnabled = false})
            }
            if shelter.phone == "" {
                DispatchQueue.main.async(execute: {self.PhoneButton.isEnabled = false})
            }
            let htmlString = self.configureView(pet, s: shelter);
            DispatchQueue.main.async(execute: {
                if self.webView == nil {
                    //self.imageURLs = (self.pet?.getAllImagesOfACertainSize("x"))!
                    //self.getImage()
                    let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
                    let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                    let wkUController = WKUserContentController()
                    wkUController.addUserScript(userScript)
                    let wkWebConfig = WKWebViewConfiguration()
                    wkWebConfig.userContentController = wkUController
                    self.webView = WKWebView(frame: CGRect(x: 0, y: (self.view.frame.size.height), width: self.view.frame.width, height: self.view.frame.height - (self.view.frame.size.height)), configuration: wkWebConfig)
                    self.webView.tag = -1112
                    self.webView!.isOpaque = false
                    self.webView!.backgroundColor = UIColor.clear
                    self.webView!.scrollView.backgroundColor = UIColor.clear
                    self.webView.translatesAutoresizingMaskIntoConstraints = false
                    self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
                    self.view.addSubview(self.webView!)
                    self.webView.scrollView.delegate = self
                    self.webView.frame = self.container.frame
                }
            })
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == 0) {
            print("At top")
        } else {
            print(scrollView.contentOffset.y / scrollView.contentSize.height)
            print("NOT at top")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        /*
         print("\(webView.frame)")
         webView.delegate = self
         webView.dataDetectorTypes = UIDataDetectorTypes.link
         //WKSelectionGranularityCharacter
         */
         favoriteBtn?.delegate = self
        
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationController?.setToolbarHidden(false, animated: false)
        //self.navigationController?.toolbar.barTintColor = UIColor.blue
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if (!Favorites.loaded) {Favorites.LoadFavorites(tv: nil)}
        
        if (Favorites.isFavorite(petID!, dataSource: favoriteType)) {
            favoriteBtn?.isSelected = true
            print("WillAppear favorited")
            favorited = true
            wasFavoritedBefore = true
        } else {
            favoriteBtn?.isSelected = false
            print("WillAppear NOT favorited")
            favorited = false
            wasFavoritedBefore = false
        }
        
        self.title = "\(petName!)"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Pictures") {
            (segue.destination as! PetFinderPicturesViewController).petData = pet!
            
        } else if (segue.identifier == "ShowYouTubeVideo") {
            (segue.destination as! YouTubeViewController).youtubeid = pet!.videos[0].videoID
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var CatImage: UIImageView!
    
    @IBOutlet weak var LocationButton: UIButton!
    
    @IBOutlet weak var PhoneButton: UIButton!
    
    @IBOutlet weak var EmailButton: UIButton!
    
    @IBOutlet weak var GalleryButton: UIButton!
    
    @IBOutlet weak var VideoButton: UIButton!

    @IBOutlet weak var ShareButton: UIButton!
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var CatNameLabel: UILabel!
    
    @IBOutlet weak var CatBreedLabel: UILabel!
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var favoriteBtn: FaveButton?
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var bottomBackground: UIImageView!
    
    var webView: WKWebView!
    
}
