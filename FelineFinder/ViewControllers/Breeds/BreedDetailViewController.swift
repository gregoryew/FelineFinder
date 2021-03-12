//
//  BreedDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedDetailViewController: UIViewController, toolBar, UISearchBarDelegate, AdoptionDismiss {
    
    @IBOutlet weak var breedPhoto: UIImageView!
    @IBOutlet weak var breedName: UILabel!
    @IBOutlet weak var toolbar: Toolbar!
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var childView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var ChildContainerHeight: NSLayoutConstraint!
    
    var breeds = [Breed]()
    var filteredBreeds: [Breed] = []
    var breed: Breed?
    var priorChildViewController: UIViewController?
    var childContainerExpanded = false
    var originalRect: CGRect!
    var currentChild = 0
    var priorBreed: Breed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        showBreedDetail(breed: breed!)
        toolbar.delegate = self
        searchBar.delegate = self
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.filteredBreeds = breeds
        }
        self.menuItemChoosen(option: 2)
    }
    
    private var infoViewController:BreedInfoViewController {
        if(_infoViewController == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _infoViewController = storyboard.instantiateViewController(withIdentifier: "BreedInfo") as? BreedInfoViewController

            _infoViewController!.breed = breed
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: _infoViewController!)
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
            self.add(asChildViewController: _statsViewController!)
            
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
            self.add(asChildViewController: _galleryViewController!)
        }
        return _galleryViewController!
    }

    var _galleryViewController:BreedGalleryViewController?
    
    private func add(asChildViewController viewController: UIViewController) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //toolbar.frame = CGRect(x: view.frame.maxX - (2 * toolbar.frame.width) - 13, y: toolbar.frame.minY, width: toolbar.frame.width, height: toolbar.frame.height)
        originalRect = toolbar.frame
    }
    
    func menuItemChoosen(option: Int) {
        //toolbar.frame = self.originalRect
        
        if option != 0 {currentChild = option}
        
        if priorChildViewController != nil && option != 0 {
            remove(asChildViewController: priorChildViewController!)
        }
        
        switch option {
        case 3:
            add(asChildViewController: infoViewController)
        case 2:
            add(asChildViewController: statsViewController)
        case 1:
            add(asChildViewController: galleryViewController)
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            guard let adopt = storyboard.instantiateViewController(withIdentifier: "AdoptList") as? AdoptableCatsCollectionViewViewController else { return }

            adopt.delegate = self

            self.present(adopt, animated: true, completion: nil)
        default: break
        }
    }
    
    func Setup() -> String {
        return breed?.BreedName ?? ""
    }
    
    func AdoptionDismiss(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
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
