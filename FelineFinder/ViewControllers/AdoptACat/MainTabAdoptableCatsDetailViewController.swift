//
//  MainTabAdoptableCatsDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import FaveButton
import WebKit
import SDWebImage

enum detailCollectionViewTypes: Int {
    case tools = 1
    case media = 2
}

class MainTabAdoptableCatsDetailViewController: UIViewController, UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, HorizontalLayoutVaryingWidthsLayoutDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var photo: UIImageView!
    //@IBOutlet weak var heart: FaveButton!
    @IBOutlet weak var PetName: UILabel!
    @IBOutlet weak var breed: UILabel!
    @IBOutlet weak var stats: UILabel!
    @IBOutlet weak var location: UILabel!

    @IBOutlet weak var toolsToolBar: UICollectionView!
    @IBOutlet weak var toolbarWidth: NSLayoutConstraint!

    @IBOutlet weak var mediaToolBar: UICollectionView!
    @IBOutlet weak var mediaToolbarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionWK: WKWebView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var topMenu: UIView!
    
    @IBOutlet weak var descriptionWKHeight: NSLayoutConstraint!

    var pet: Pet!
    var tools: Tools!
    var media: Tools!
    
    private var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tools = Tools.init(pet: self.pet, shelter: globalShelterCache[self.pet.shelterID]!, sourceView: self.view)
        media = Tools.init(pet: self.pet, shelter: globalShelterCache[pet.shelterID]!, sourceView: self.view)
        
        if let imgURL = URL(string: pet.getImage(1, size: "x")) {
        self.photo.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority, completed: nil)
        } else {
            self.photo.image = UIImage(named: "NoCatImage")
        }
        
        self.PetName.text = pet.name
        
        self.breed.text = pet.breeds.first
        
        var options = [String]()
        if pet.status != "" {
            options.append(pet.status)
        }
        if pet.age != "" {
            options.append(pet.age)
        }
        if pet.sex != "" {
            options.append(pet.sex)
        }
        if pet.size != "" {
            options.append(pet.size)
        }
        stats.text = options.joined(separator: " | ") + " "
        
        var location = [String]()
        if pet.location != "" {
            location.append(pet.location)
        }
        if pet.distance != 0 {
            location.append("\(pet.distance) Miles")
        }
        self.location.text = location.joined(separator: " - ") + " "
        
        toolsToolBar.tag = detailCollectionViewTypes.tools.rawValue
        tools.mode = .tools
        toolsToolBar.dataSource = self
        toolsToolBar.delegate = self
        
        let toolslayout = toolsToolBar.collectionViewLayout as! HorizontalLayoutVaryingWidths
        toolslayout.delegate = self
        toolslayout.numberOfRows = 1
        toolslayout.cellPadding = 2.5
        toolslayout.columnHeight = 65
        
        toolbarWidth.constant = CGFloat(tools.count() * 65)
        
        mediaToolBar.tag = detailCollectionViewTypes.media.rawValue
        media.mode = .media
        mediaToolBar.dataSource = self
        mediaToolBar.delegate = self
        
        var mediaWidth: CGFloat = 0.0
        for m in media {
            if m.cellType == .image {
                let photo = m as! imageTool
                let ratio = CGFloat(100.0) / CGFloat(photo.thumbNail.height)
                mediaWidth += CGFloat(photo.thumbNail.width) * ratio
            } else if m.cellType == .video {
                mediaWidth += 133
            }
        }
        if CGFloat(mediaWidth) < view.frame.width {
             mediaToolbarWidth.constant = CGFloat(mediaWidth)
        } else {
            mediaToolbarWidth.constant = view.frame.width
        }
        
        let medialayout = mediaToolBar.collectionViewLayout as! HorizontalLayoutVaryingWidths
        medialayout.delegate = self
        medialayout.numberOfRows = 1
        medialayout.cellPadding = 2.5
        
        descriptionWK.navigationDelegate = self

        let path = Bundle.main.bundlePath;
        let sBaseURL = URL(fileURLWithPath: path);
        let description2 = (tools.list[0] as! descriptionTool).generatePetDescription()
        descriptionWK.loadHTMLString(description2, baseURL: sBaseURL)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScrollView()
        scrollView.addSubview(self.contentView)
        scrollView.delegate = self
        
        let contentLayoutGuide = scrollView.contentLayoutGuide
         
        NSLayoutConstraint.activate([
           //3
            view.widthAnchor.constraint(equalTo:
             contentView.widthAnchor),
            contentView.leadingAnchor.constraint(equalTo:
             contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo:
             contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo:
             contentLayoutGuide.topAnchor),
           //4
            contentView.bottomAnchor.constraint(equalTo:
             contentLayoutGuide.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: contentLayoutGuide.heightAnchor)
        ])
    }
    
    private func setupScrollView() {
      //1
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(scrollView)
        
      //2
      NSLayoutConstraint.activate([
        scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        scrollView.heightAnchor.constraint(equalToConstant: (self.view.frame.height - topMenu.frame.height)),
        scrollView.leadingAnchor.constraint(equalTo:
          view.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo:
          view.trailingAnchor),
        scrollView.topAnchor.constraint(equalTo: topMenu.bottomAnchor),
        self.contentView.bottomAnchor.constraint(equalTo: self.descriptionWK.bottomAnchor),
        //scrollView.bottomAnchor.constraint(equalTo:
        //                                    self.contentView.bottomAnchor)
      ])
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            return 65
        case detailCollectionViewTypes.media.rawValue:
            if media[indexPath.item] is imageTool {
                let h = CGFloat((media[indexPath.item] as? imageTool)?.thumbNail.height ?? 95)
                let ratio = 95.0 / h
                return CGFloat((media[indexPath.item] as? imageTool)?.thumbNail.width ?? 95) * ratio
            } else {
                return 133
            }
        default: return 0
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ListIconTapped(_ sender: Any) {
    }
    
    @IBAction func filterTapped(_ sender: Any) {
    }
    
    @IBAction func heartTapped(_ sender: Any) {
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            print("tools count = \(tools.count())")
            print("tools datasource set \(String(describing: collectionView.dataSource))")
            print("tools delegate set \(String(describing: collectionView.delegate))")
            return tools.count()
        case detailCollectionViewTypes.media.rawValue:
            print("media count = \(media.count())")
            print("media datasource set \(String(describing: collectionView.dataSource))")
            print("media delegate set \(String(describing: collectionView.delegate))")
            return media.count()
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            let cell = toolsToolBar.dequeueReusableCell(withReuseIdentifier: "toolCell", for: indexPath) as! ToolCell
            cell.configure(tool: tools[indexPath.item])
            return cell
        case detailCollectionViewTypes.media.rawValue:
            let cell = mediaToolBar.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as! mediaCell
            cell.configure(mediaTool: media[indexPath.item], isSelected: true)
            return cell
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            tools[indexPath.item].performAction()
        case detailCollectionViewTypes.media.rawValue:
            media[indexPath.item].performAction()
        default: break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        //self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 550 + (self.mediaToolBar.frame.maxY))
    }
}

extension MainTabAdoptableCatsDetailViewController : WKNavigationDelegate {
/*
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Handel Dynamic Height For Webview Loads with HTML
       // Most important to reset webview height to any desired height i prefer 1 or 0
        webView.frame.size.height = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        // here get height constant and assign new height in it
            if let constraint = (webView.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = webView.scrollView.contentSize.height
            }
        }
    }
 */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in

        if complete != nil {
            let height = webView.scrollView.contentSize.height
            self.descriptionWKHeight.constant = height
            //self.contentViewHeight.constant = height + (self.mediaToolBar.frame.maxY)
            print("height of webView is: \(height)")
            self.view.setNeedsLayout()
        }
      })
    }
}
