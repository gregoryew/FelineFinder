//
//  DetailCellList.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/21/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import MapKit
import Social
import WebKit

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
    var delegate: ToolbarDelegate?
    
    init(pet: Pet, shelter: shelter?, sourceView: UIView) {
        self.pet = pet
        self.shelter = shelter
        self.sourceView = sourceView
    }
    
    init(pet: Pet, shelter: shelter?, sourceView: UIView, delegate: ToolbarDelegate) {
        self.delegate = delegate
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
        let appleURL = "https://maps.apple.com/?daddr=\(lat),\(lng)"
        let googleURL = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)"
        let wazeURL = "waze://?ll=\(lat),\(lng)&n=T"

        let googleItem = ("Google Map", URL(string:googleURL)!)
        let wazeItem = ("Waze", URL(string:wazeURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }

        //if UIApplication.shared.canOpenURL(wazeItem.1) {
            installedNavigationApps.append(wazeItem)
        //}

        let actionSheetController: UIAlertController = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
            })
            actionSheetController.addAction(button)
        }
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = sourceViewController!.view
        //actionSheetController.popoverPresentationController? = PhoneButton
        
        //Present the AlertController
        sourceViewController!.present(actionSheetController, animated: true, completion: nil)
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
        return ""
    }
}

class emailTool: Tool {
    var emailAddress = [String]()
    override init(pet: Pet, shelter: shelter?, sourceView: UIView, delegate: ToolbarDelegate) {
        super.init(pet: pet, shelter: shelter, sourceView: sourceView, delegate: delegate)
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
        delegate?.createEmail(pet: pet!, shelter: shelter!)
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
                                    let vc = self.sourceView?.findViewController() as! AdoptableCatsDetailViewController
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
    var delegate: ToolbarDelegate?
    private var currentIndex: Int = 0
    private var breed: Breed?
    private var sourceView: UIView?
    
    var mode = Mode.media {
        didSet {
            currentIndex = 0
            tools = getTools()
        }
    }
    
    init(pet: Pet, shelter: shelter, sourceView: UIView, delegate: ToolbarDelegate) {
        list = []
        list.append(descriptionTool(pet: pet, shelter: shelter, sourceView: sourceView))
        list.append(emailTool(pet: pet, shelter: shelter, sourceView: sourceView, delegate: delegate))
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
                self.list.append(youTubeTool(breed: breed, sourceView: sourceView, video: video(i: String(count), o: String(count), t: vid.pictureURL, v: vid.videoID, u: "", title: vid.title)))
            }
        }
        
        /*
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
        */
 
        tools = getTools()
    }
    
    func getTools() -> [Tool] {
        tools = [Tool]()
        for item in self.list {
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
