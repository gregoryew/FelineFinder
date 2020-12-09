//
//  DetailCellList.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/21/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import MessageUI
import MapKit
import Social
import WebKit
import CMMapLauncher

class Tool {
    var icon = ""
    var title = ""
    var visible = true
    var cellType: CellType = .tool
    
    var pet: Pet?
    var shelter: shelter?
    var breed: Breed?
    var sourceView: UIView?
    var sourceViewController: UIViewController?

    init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        self.pet = pet
        self.shelter = shelter
        self.sourceView = sourceView
    }
    
    init(breed: Breed, sourceView: UIView) {
        self.breed = breed
        self.sourceView = sourceView
    }

    func isVisible(mode: Mode) -> Bool {
        return visible
    }
    
    func performAction() {
        print (icon)
        if sourceViewController == nil {
            if let vc = sourceView?.findViewController() {
                sourceViewController = vc
            }
        }
    }
}

class directionsTool: Tool {
    override init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "Tool_Directions"
        title = "Directions"
        cellType = .tool
    }
    
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        let address = shelter!.address1.uppercased().replacingOccurrences(of: " ", with: "")
        return !(address.hasPrefix("POBOX") || address.hasPrefix("P.O.") || address == "") && mode == .tools
    }
    
    override func performAction() {
        super.performAction()
        loadCoordinate(sh: shelter!)
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
    
    func parseStreetAddress(_ s: String) -> NSString {
        var sa: String = s.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
        sa = sa.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        sa = sa.uppercased()
        var s2 = sa as NSString
        s2 = s2.substring(with: NSRange(location: 0, length: 5)) as NSString
        return s2
    }
}

/*
protocol scrolledView {
    func viewScrolled(scrollView: UIScrollView)
}
 */

class descriptionTool: Tool { //, scrolledView {
    
    var description = ""

    override init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "📄"
        title = "Text"
        cellType = .tool
    }

    override init(breed: Breed, sourceView: UIView) {
        super.init(breed: breed, sourceView: sourceView)
        icon = "📄"
        cellType = .tool
    }
    
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return false
    }
    
    override func performAction() {
        super.performAction()
        diplayDescription()
    }

    var blurEffectView: UIVisualEffectView!
    var wv: WKWebView!
        
    func diplayDescription() {
        if let sv = sourceView {
            UIView.transition(with: sv, duration: 0.5, options: .transitionFlipFromLeft , animations: { [self] in
                //Do the data reload here
            wv = WKWebView(frame: sv.bounds)
            var description2 = ""
            if pet != nil {
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = sv.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                sv.addSubview(blurEffectView)
                description2 = generatePetDescription()
                wv.isOpaque = false
                wv.backgroundColor = UIColor.clear
                let path = Bundle.main.bundlePath;
                let sBaseURL = URL(fileURLWithPath: path);
                sv.addSubview(wv)
                wv.loadHTMLString(description2, baseURL: sBaseURL)
            } else {
                sv.addSubview(wv)
                if let url = URL(string: breed!.BreedHTMLURL) {
                    let request = URLRequest(url: url)
                    wv.load(request)
                }
            }
            sourceViewController!.view.addSubview(sideBar)
            sideBar.frame = CGRect(x: sourceViewController!.view.frame.width - 60, y: 50, width: 60, height: 30)
            sourceViewController!.view.bringSubviewToFront(sideBar)
            }, completion: nil)
            //(sourceViewController as! MainTabAdoptableCats).delegate = self
        }
    }
    
    lazy var sideBar: UIView = {
        let toolBarView: UIView!
        toolBarView = UIView(frame: CGRect(x: sourceViewController!.view.frame.width - 60, y: 50, width: 60, height: 30))

        toolBarView.backgroundColor = .green
        toolBarView.layer.shadowRadius = 5
        toolBarView.layer.shadowOpacity = 0.8
        toolBarView.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        let backBtn = UIButton(type: .roundedRect)
        backBtn.setTitle("Done", for: .normal)
        toolBarView.addSubview(backBtn)
        backBtn.addTarget(self, action: #selector(backTapped), for:  .touchUpInside)
        backBtn.frame = CGRect(x: 5, y: 0, width: 50, height: 30)
        
        let traits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold] // UIFontWeightBold / UIFontWeightRegular
        var imgFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Helvetica"])
        imgFontDescriptor = imgFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: traits])
        
        backBtn.titleLabel!.font = UIFont(descriptor: imgFontDescriptor, size: 0)
        backBtn.titleLabel?.textColor = UIColor.white
        
        return toolBarView
    }()

/*
    func viewScrolled(scrollView: UIScrollView) {
        sideBar.frame = CGRect(x: sourceViewController!.view.frame.width - 30, y: scrollView.contentOffset.y + 20, width: 30, height: 50);
        sourceViewController!.view.bringSubviewToFront(sideBar)
    }
*/
    @IBAction func backTapped(_ sender: Any) {
        UIView.transition(with: sourceView!, duration: 0.5, options: .transitionFlipFromRight , animations: { [self] in
            //Do the data reload here
            sideBar.removeFromSuperview()
            if pet != nil  {
                blurEffectView.removeFromSuperview()
            }
            wv.removeFromSuperview()
        }, completion: nil)
    }
    
    func generatePetDescription() -> String {
        var htmlString = ""
        if let pet = pet, let shelter = shelter {
        var b: String = ""
        for b2 in pet.breeds {
            if (b == "") {
                b = "\(b2)"
            }
            else {
                b = "\(b) & \(b2)"
            }
        }

        var o: String = ""
        for o2 in pet.options {
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

        var html: String = ""
        html = "\(html)<tr><td><b>Address:</b></td></tr>"
        if (shelter.name != "") {
            html = "\(html)<tr><td>\(shelter.name)</td></tr>"
        }
            if (shelter.address1 != "") {
            html = "\(html)<tr><td>\(shelter.address1)</td></tr>"
        }
        if (shelter.address2 != "") {
            html = "\(html)<tr><td>\(shelter.address2)</td></tr>"
        }
        var c: String = ""
        var st: String = ""
        var z: String = ""
        if (shelter.city != "") {
            c = shelter.city
        }
        if (shelter.state != "") {
            st = shelter.state
        }
        if (shelter.zipCode != "") {
            z = shelter.zipCode
        }
        if (z != "" || c != "" || st != "") {
            html = "\(html)<tr><td>\(c), \(st) \(z)</td></tr>"
        }
        html = "\(html)<tr><td><a href=\"launchLocation\">Driving Directions</a></td></tr>"
        html = "\(html)<tr><td>&nbsp;</td></tr><tr><td><b>Contact Info</b></td></tr>"
        if (shelter.email != "") {
            if (shelter.phone != "") {
                html = "\(html)<tr><td>&nbsp;</td></tr>"
            }
            html = "\(html)<tr><td><a href=\"mailto:\(shelter.email)\">E-Mail: \(shelter.email)</a></td></tr>"
        }
        if (shelter.phone != "") {
            if (shelter.email != "") {
                html = "\(html)<tr><td>&nbsp;</td></tr>"
            }
            html = "\(html)<tr><td><a href=\"tel:\(shelter.phone)\">Call: \(shelter.phone)</a></td></tr>"
            html = "\(html)<tr><td>&nbsp;</td></tr>"
        }
        html = "\(html)<tr><td><a href=\"Share\">Share</a></td></tr>"
        
        var headerContent: String = "<tr><td style=\"background-color:#8AC007\">Basics:</td><td>\(b) • \(pet.age) • \(pet.sex) • \(pet.size)</td></tr>"
        headerContent = "\(headerContent)<tr><td style=\"background-color:#8AC007\">Options:</td><td>\(o)</td></tr>"
        
        /*
        var born = ""
        if p.birthdate != "" {
            born = "<h1>Born \(p.birthdate)</h1>"
        }
        */
        
        var options = ""
        if b != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(b)</br></br>"
        }
        if pet.age != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(pet.age)</br></br>"
        }
        if pet.sex != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(pet.sex)</br></br>"
        }
        if pet.size != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(pet.size)</br></br>"
        }
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MM/dd/yyyy"
        //let d = dateFormatter.string(from: p.lastUpdated)
        
            htmlString = "<!DOCTYPE html><html><header><style> li {margin-top: 30px;border:1px solid grey;} li:first-child {margin-top:0;} h1 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:24px;} h2 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:36px;} h3 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:28px;} h4 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px;} a { color: #66ff33} a.visited, a.hover {color: blue;} </style></header><body><center><table width=\"\(self.tableWidth())\"><tr><td width=\"100%\"><table width=\"100%\"><tr><td><h3><b>GENERAL INFORMATION</b></h3></center><h2></td></tr></table><h1>\(options)\(o)</br></h1><table><tr><td><center><h2>CONTACT</h2></center><h1>\(shelter.name)</br>\(shelter.address1)</br>\(c), \(shelter.state) \(shelter.zipCode)</h1></td></tr><tr><td><h2><center>DESCRIPTION</center></h2><div style='overflow-y:visible; overflow-x:scroll; width:\(self.width())'><h1><p style=\"word-wrap: break-word;\">\(pet.descriptionHtml)</p></h1></div></td></tr><tr><td></td></tr><tr><td><h2><center>DISCLAIMER</center></h2><h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.</h4></td></tr></table></center></body></html>"
        }
        return htmlString
    }
    
    func generateBreedDescription() -> String {
        if let b = breed {
            let myURLString = b.BreedHTMLURL
            guard let myURL = URL(string: myURLString) else {
                print("Error: \(myURLString) doesn't seem to be a valid URL")
                return ""
            }

            do {
                let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                return myHTMLString
            } catch let error {
                print("Error: \(error)")
                return ""
            }
        } else {
            return ""
        }
    }
    
    func width() -> String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "640px"
        } else {
            return "900px"
        }
    }
    
    func tableWidth() -> Int {
        var tableWidth = 0
        if UIDevice().type == Model.iPhone5 || UIDevice().type == Model.iPhone5C || UIDevice().type == Model.iPhone5S {
            tableWidth = 300
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            tableWidth = 900 //360
        } else {
            tableWidth = 700
        }
        return tableWidth
    }
}

class emailTool: Tool {
    var emailAddress = [String]()
    override init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "Tool_Email"
        title = "Email"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return shelter!.email != "" && mode == .tools
    }
    override func performAction() {
        super.performAction()
        sendEmail()
    }
    func sendEmail() {
        var email = shelter?.email
        if (email?.lowercased().hasPrefix("emailto"))! {
            email = (shelter?.email.chopPrefix(7))!
        }
        emailAddress = [String]()
        emailAddress.append(email!)
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            sourceViewController!.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = (sourceViewController! as! MFMailComposeViewControllerDelegate) // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(emailAddress)
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        Utilities.displayAlert("Could Not Send Email", errorMessage: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
}

class telephoneTool: Tool {
    var phoneNumber = ""
    
    override init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "Tool_Call"
        title = "Call"
        cellType = .tool
    }
    
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return shelter!.phone != "" && mode == .tools
    }
    
    override func performAction() {
        super.performAction()
        call()
    }
    
    func call() {
        let p: String = shelter?.phone ?? ""
        
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
        let actionSheetController: UIAlertController = UIAlertController(title: "Call \(shelter!.name)?", message: "Do you want to call \(shelter!.name) at \(shelter!.phone) now?", preferredStyle: .actionSheet)
        
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
        actionSheetController.popoverPresentationController?.sourceView = sourceViewController!.view
        //actionSheetController.popoverPresentationController? = PhoneButton
        
        //Present the AlertController
        sourceViewController!.present(actionSheetController, animated: true, completion: nil)
    }
}

class shareTool: Tool {
    var description = ""
    var vc: UIActivityViewController?
    var loaded: Bool = false
    
    override init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "Tool_Share"
        title = "Share"
        cellType = .tool
    }
    
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    
    override func performAction() {
        super.performAction()
        share()
    }
    
    func share() {
        if let s = shelter {
        var imageCache: [UIImage] = []
        var errors = 0
        let imgs: [String] = pet!.getAllImagesOfACertainSize("pn")
        imageCache.removeAll()
        var address: String = ""
        if s.address1 != "" {
            address += "\(s.address1)"
        }
        if s.address2 != "" && address != "" {
            address += "\r\n\(s.address2)"
        } else {
            address += s.address2
        }
        if (s.city != "" || s.state != "" || s.zipCode != "") && address != ""  {
            address += "\r\n\(s.city), \(s.state) \(s.zipCode)"
        } else {
            address += "\(s.city), \(s.state) \(s.zipCode)"
        }
        if (address != "") {
            address += "\r\n\r\nAddress:\r\n\(s.name)\r\n\(address)"
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
                            self.vc = UIActivityViewController(activityItems: imageCache + ["About \(self.pet!.name)\r\n\(self.pet!.description) \(address) \r\n\r\nContact Info\r\n\(self.shelter!.email)\r\n\(self.shelter!.phone)" ], applicationActivities: [])
                            //presentViewController(vc!, animated: true, completion: nil)
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                                self.sourceView?.findViewController()!.present(self.vc!, animated: true, completion: nil)
                                self.loaded = false
                            } else {
                                let ac = UIActivityViewController(activityItems: imageCache + ["About \(self.pet!.name)\r\n\(self.pet!.description) \(address) \r\n\r\nContact Info\r\n\(self.shelter!.email)\r\n\(self.shelter!.phone)" ], applicationActivities: nil)
                                if let popOver = ac.popoverPresentationController {
                                    popOver.sourceView = self.sourceView
                                    let vc = self.sourceView?.findViewController() as! MainTabAdoptableCatsDetailViewController
                                    popOver.sourceRect = CGRect(x: (self.sourceView!.frame.width / 2) - 100, y: (self.sourceView!.frame.height / 2) - 100, width: 200, height: 200)
                                    vc.present(ac, animated: true)
                                }
                                self.loaded = false
                            }
                        })
                    }
                } else {
                    errors += 1
                }
            }).resume()
        }
        }
    }
}

class statsTool: Tool {
    override init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "📊"
        title = "Stats"
        cellType = .tool
    }
    override init(breed: Breed, sourceView: UIView) {
        super.init(breed: breed, sourceView: sourceView)
        icon = "📊"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return false
    }
    override func performAction() {
        super.performAction()
    }
}

class imageTool: Tool {
    var thumbNail: picture2
    var photo: picture2

    init(pet: Pet, shelter: shelter?, sourceView: UIView, thumbNail: picture2, photo: picture2) {
        self.thumbNail = thumbNail
        self.photo = photo
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "🖼️"
        title = "Photo"
        cellType = .image
    }

    init(breed: Breed, sourceView: UIView, thumbNail: picture2, photo: picture2) {
        self.thumbNail = thumbNail
        self.photo = photo
        super.init(breed: breed, sourceView: sourceView)
        icon = "🖼️"
        cellType = .image
    }
    
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .media
    }
    
    override func performAction() {
        super.performAction()
    }
}

class youTubeTool: Tool {
    var video: video
    
    init(pet: Pet, shelter: shelter, sourceView: UIView, video: video) {
        self.video = video
        super.init(pet: pet, shelter: shelter, sourceView: sourceView)
        icon = "🎞️"
        title = "Video"
        cellType = .video
    }

    init(breed: Breed, sourceView: UIView, video: video) {
        self.video = video
        super.init(breed: breed, sourceView: sourceView)
        icon = "🎞️"
        cellType = .video
    }
    
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .media
    }
    
    override func performAction() {
        super.performAction()
        let YouTubePlayerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YouTubeVidePlayer") as! YouTubeViewController
        YouTubePlayerVC.youTubeVideoID = video.videoID
        if let sourceVideoController = sourceViewController {
            sourceVideoController.present(YouTubePlayerVC, animated: true, completion: nil)
        }
    }
}


enum Mode: String {
    case tools = "tools"
    case media = "media"
}

enum CellType: String {
    case tool = "tool"
    case image = "image"
    case video = "video"
}

class Tools: Sequence, IteratorProtocol {
    typealias Element = Tool
    
    var list = [Tool]()
    var tools = [Tool]()
    private var currentIndex: Int = 0
    private var breed: Breed?
    private var sourceView: UIView?
    
    var mode = Mode.media {
        didSet {
            currentIndex = 0
            tools = getTools()
        }
    }
    
    init(pet: Pet, shelter: shelter, sourceView: UIView) {
        list = []
        list.append(descriptionTool(pet: pet, shelter: shelter, sourceView: sourceView))
        list.append(emailTool(pet: pet, shelter: shelter, sourceView: sourceView))
        list.append(shareTool(pet: pet, shelter: shelter, sourceView: sourceView))
        list.append(directionsTool(pet: pet, shelter: shelter, sourceView: sourceView))
        list.append(telephoneTool(pet: pet, shelter: shelter, sourceView: sourceView))
        list.append(statsTool(pet: pet, shelter: shelter, sourceView: sourceView))
        
        let thumbNails = pet.getAllImagesObjectsOfACertainSize("pnt")
        let photos = pet.getAllImagesObjectsOfACertainSize("x")
        for i in 0..<photos.count {
            list.append(imageTool(pet: pet,
                                  shelter: shelter,
                                  sourceView: sourceView,
                                  thumbNail: thumbNails[i],
                                  photo: photos[i]))
        }
        
        for video in pet.videos {
            list.append(youTubeTool(pet: pet,
                                    shelter: shelter, sourceView: sourceView, video: video))
        }
        
        tools = getTools()
    }

    init(breed: Breed, sourceView: UIView, obj: NSObject?) {
        list = []
        list.append(descriptionTool(breed: breed, sourceView: sourceView))
        list.append(statsTool(breed: breed, sourceView: sourceView))
        self.breed = breed
        self.sourceView = sourceView
                
        switch YouTubeAPI.getYouTubeVideos(playList: breed.YouTubePlayListID) {
        case .failure(let err):
            Utilities.displayAlert("Network Error", errorMessage: err.localizedDescription)
        case .success(let data):
            var count = 0
            for vid in data! {
                count += 1
                self.list.append(youTubeTool(breed: breed, sourceView: sourceView, video: video(i: String(count), o: String(count), t: vid.pictureURL, v: vid.videoID, u: "")))
            }
        }
        
        switch RescueGroups().getPets(zipCode: zipCode, breed: breed) {
        case .failure(let err):
            Utilities.displayAlert("Network Error", errorMessage: err.localizedDescription)
        case .success(let data):
            for pet in data! {
                if let thumbNail = pet.getAllImagesObjectsOfACertainSize("pn").first, let large = pet.getAllImagesObjectsOfACertainSize("x").first {
                    let imgTool = imageTool(pet: pet, shelter: nil, sourceView: sourceView, thumbNail: thumbNail, photo: large)
                    self.list.append(imgTool)
                }
            }
        }

        tools = getTools()
    }
    
    func getTools() -> [Tool] {
        var tools = [Tool]()
        for item in list {
            if item.isVisible(mode: mode) {
                tools.append(item)
            }
        }
        return tools
    }
        
    subscript(index: Int) -> Tool {
        return tools[index]
    }
    
    func count() -> Int {
        return tools.count
    }
    
    func images() -> [imageTool] {
        var images = [imageTool]()
        for tool in tools {
            if tool.cellType == .image {
                images.append(tool as! imageTool)
            }
        }
        return images
    }
    
    func youTubeVidoes() -> [youTubeTool] {
        var youTubeVideos = [youTubeTool]()
        for tool in tools {
            if tool.cellType == .video {
                youTubeVideos.append(tool as! youTubeTool)
            }
        }
        return youTubeVideos
    }
    
    func next() -> Tool? {
        defer { currentIndex += 1 }
        return currentIndex < tools.count ? tools[currentIndex] : nil
    }
}
