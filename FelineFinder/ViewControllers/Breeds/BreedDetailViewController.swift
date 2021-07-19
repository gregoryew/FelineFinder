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
    
    var breeds = [Breed]()
    var filteredBreeds: [Breed] = []
    var breed: Breed?
    var priorChildViewController: UIViewController?
    var childContainerExpanded = false
    var originalRect: CGRect!
    var currentChild = 0
    var priorBreed: Breed?
    
    var tools: [(btn: UIButton, images: [String])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        showBreedDetail(breed: breed!)
        searchBar.delegate = self
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.filteredBreeds = breeds
        }
        
        tools = [(btn: catButton, images: ["Tool_Cat", "Tool_Filled_Cat"]),
                 (btn: videoButton, images: ["Tool_Video", "Tool_Filled_Video"]),
                 (btn: statsButton, images: ["Tool_Stats", "Tool_Filled_Stats"]),
                 (btn: infoButton, images: ["Tool_Info", "Tool_Filled_Info"])]

        self.menuItemChoosen(option: 2)

    }
    
    @IBAction func catButtonTapped(_ sender: Any) {
        menuItemChoosen(option: 0)
    }
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        menuItemChoosen(option: 1)
    }
    
    @IBAction func statsButtonTapped(_ sender: Any) {
        menuItemChoosen(option: 2)
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        menuItemChoosen(option: 3)
    }
    
    private var infoViewController:BreedInfoViewController {
        if(_infoViewController == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _infoViewController = storyboard.instantiateViewController(withIdentifier: "BreedInfo") as? BreedInfoViewController

            _infoViewController!.breed = breed
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: _infoViewController!, option: 3)
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
            self.add(asChildViewController: _statsViewController!, option: 2)
            
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
            self.add(asChildViewController: _galleryViewController!, option: 1)
        }
        return _galleryViewController!
    }

    var _galleryViewController:BreedGalleryViewController?
    
    private func add(asChildViewController viewController: UIViewController, option: Int) {
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
    
    func showBreedDetail(breed: Breed) {
        breedPhoto.image = UIImage(named: breed.FullSizedPicture)
        breedName.text = breed.BreedName
        self.breed = breed
    }
    
    func menuItemChoosen(option: Int) {
        if option != 0 {currentChild = option}
        
        if priorChildViewController != nil && option != 0 {
            remove(asChildViewController: priorChildViewController!)
        }
        
        switch option {
        case 3:
            add(asChildViewController: infoViewController, option: option)
        case 2:
            add(asChildViewController: statsViewController, option: option)
        case 1:
            add(asChildViewController: galleryViewController, option: option)
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            // Instantiate View Controller
            guard let adoptVC = storyboard.instantiateViewController(withIdentifier: "AdoptList") as? AdoptableCatsCollectionViewViewController else { return }
            adoptVC.delegate = self
            self.present(adoptVC, animated: true, completion: nil)
        default: break
        }

        for tool in tools {
            tool.btn.setImage(UIImage(named:tool.images[0]), for: .normal)
        }
        tools[currentChild].btn.setImage(UIImage(named:tools[currentChild].images[1]), for: .normal)
        
    }
    
    override func Dismiss(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
    }
    
    override func Download(reset: Bool) {
        DownloadManager.loadPets(ofBreed: breed!, reset: reset)
    }
    
    override func GetTitle(totalRows TotalRows: Int) -> String {
        return String(TotalRows) + " of " + (breed?.BreedName ?? "") + " breed"
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
        showBreedDetail(breed: (filteredBreeds.first ?? breed)!)
        if priorBreed?.BreedID != breed?.BreedID {
            priorBreed = breed
            _infoViewController = nil
            _statsViewController = nil
            _galleryViewController = nil
            menuItemChoosen(option: currentChild)
        }
    }
}
