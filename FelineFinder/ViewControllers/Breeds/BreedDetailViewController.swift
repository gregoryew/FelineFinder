//
//  BreedDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedDetailViewController: ParentViewController, UISearchBarDelegate {

    @IBOutlet weak var breedPhoto: UIImageView!
    @IBOutlet weak var breedName: UILabel!
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var childView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var catButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var ChildContainerHeight: NSLayoutConstraint!
    
    enum menuOptions: Int {
    case cats = 0
    case video = 1
    case stats = 2
    case info = 3
    }
    
    var breeds = [Breed]()
    var filteredBreeds: [Breed] = []
    var priorChildViewController: UIViewController?
    var childContainerExpanded = false
    var originalRect: CGRect!
    var currentChild = menuOptions.cats
    var priorBreed: Breed?
    
    var tools: [(btn: UIButton, images: [String])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        showBreedDetail(breedParam: breed!)
        searchBar.delegate = self
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.filteredBreeds = breeds
        }
        
        tools = [(btn: catButton, images: ["Tool_Cat", "Tool_Filled_Cat"]),
                 (btn: videoButton, images: ["Tool_Video", "Tool_Filled_Video"]),
                 (btn: statsButton, images: ["Tool_Stats", "Tool_Filled_Stats"]),
                 (btn: infoButton, images: ["Tool_Info", "Tool_Filled_Info"])]

        self.menuItemChoosen(option: .info)

    }
    
    @IBAction func catButtonTapped(_ sender: Any) {
        menuItemChoosen(option: .cats)
    }
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        menuItemChoosen(option: .video)
    }
    
    @IBAction func statsButtonTapped(_ sender: Any) {
        menuItemChoosen(option: .stats)
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        menuItemChoosen(option: .info)
    }
    
    private var infoViewController:BreedInfoViewController {
        if(_infoViewController == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _infoViewController = storyboard.instantiateViewController(withIdentifier: "BreedInfo") as? BreedInfoViewController

            _infoViewController!.breed = breed
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: _infoViewController!, option: .info)
        }
        return _infoViewController!
    }

    var _infoViewController:BreedInfoViewController?

    var statsViewController:BreedStatsViewController {
        if(_statsViewController == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _statsViewController = storyboard.instantiateViewController(withIdentifier: "BreedStats") as? BreedStatsViewController
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: _statsViewController!, option: .stats)
            
            _statsViewController!.setup(breed: breed!)
        }
        return _statsViewController!
    }

    var _statsViewController:BreedStatsViewController?

    var galleryViewController:BreedGalleryViewController {
        if(_galleryViewController == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _galleryViewController = storyboard.instantiateViewController(withIdentifier: "BreedGallery") as? BreedGalleryViewController

            _galleryViewController!.breed = breed
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: _galleryViewController!, option: .video)
        }
        return _galleryViewController!
    }

    var _galleryViewController:BreedGalleryViewController?
    
    private func add(asChildViewController viewController: UIViewController, option: menuOptions) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        childContainerView.addSubview(viewController.view)

        // Configure Child View
        childContainerView.frame = view.bounds
        childContainerView.autoresizingMask = [.flexibleWidth]
        
        viewController.view.frame = CGRect(x: 0, y: 0, width: childContainerView.frame.width, height: childContainerView.frame.height)

        // Notify Child View Controller
        viewController.didMove(toParent: self)
                
        priorChildViewController = viewController
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    func showBreedDetail(breedParam: Breed) {
        breedPhoto.image = UIImage(named: breedParam.FullSizedPicture)
        breedName.text = breedParam.BreedName
        breed = breedParam
    }
    
    func menuItemChoosen(option: menuOptions) {
        if option != .cats {currentChild = option}
        
        if priorChildViewController != nil && option != .cats {
            remove(asChildViewController: priorChildViewController!)
        }
        
        switch option {
        case .info:
            add(asChildViewController: infoViewController, option: option)
        case .stats:
            add(asChildViewController: statsViewController, option: option)
        case .video:
            add(asChildViewController: galleryViewController, option: option)
        case .cats:
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            // Instantiate View Controller
            guard let adoptVC = storyboard.instantiateViewController(withIdentifier: "AdoptList") as? AdoptableCatsCollectionViewViewController else { return }
            adoptVC.delegate = self
            self.present(adoptVC, animated: true, completion: nil)
        }

        for tool in tools {
            tool.btn.setImage(UIImage(named:tool.images[0]), for: .normal)
        }
        tools[currentChild.rawValue].btn.setImage(UIImage(named:tools[currentChild.rawValue].images[1]), for: .normal)
        
    }
    
    override func Dismiss(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
    }
    
    override func Download(reset: Bool) {
        DownloadManager.loadPets(ofBreed: breed!, reset: reset)
    }
    
    override func GetTitle(totalRows TotalRows: Int) -> String {
        if TotalRows == 0 {
            return " No " + (breed?.BreedName ?? "Cats") + " Found."
        }
        return " " + String(TotalRows) + " " + ((breed?.BreedName ?? "Cats") + " Zip: \(zipCode)")
    }
    
    @IBAction func BackTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func expandCollapseTapped(_ sender: Any) {
        childContainerExpanded = !childContainerExpanded
        UIView.animate(withDuration: 0.5) {
            if self.childContainerExpanded {
                self.expandCollapseButton.setImage(UIImage(named: "icons8-toggle-collapse-screen"), for: .normal)
                self.ChildContainerHeight.constant = 115
            } else {
                self.expandCollapseButton.setImage(UIImage(named: "icons8-toggle-expand-screen"), for: .normal)
                self.ChildContainerHeight.constant = 348
            }
        }
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filteredBreeds = breeds.filter { (breed: Breed) -> Bool in
                return breed.BreedName.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredBreeds = [breed!]
        }
        showBreedDetail(breedParam: (filteredBreeds.first ?? breed)!)
        if priorBreed?.BreedID != breed?.BreedID {
            priorBreed = breed
            _infoViewController = nil
            _statsViewController = nil
            _galleryViewController = nil
            menuItemChoosen(option: currentChild)
        }
    }
}
