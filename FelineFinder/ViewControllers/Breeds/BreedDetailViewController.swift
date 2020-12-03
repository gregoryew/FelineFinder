//
//  BreedDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedDetailViewController: UIViewController, toolBar, UISearchBarDelegate {
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
    
    private lazy var infoViewController: BreedInfoViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedInfo") as! BreedInfoViewController

        viewController.breed = breed
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var statsViewController: BreedStatsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedStats") as! BreedStatsViewController

        viewController.breed = breed
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var galleryViewController: BreedGalleryViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedGallery") as! BreedGalleryViewController

        viewController.breed = breed
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showBreedDetail(breed: breed!)
        toolbar.delegate = self
        searchBar.delegate = self
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.filteredBreeds = breeds
        }
        self.menuItemChoosen(option: 2)
    }

    func showBreedDetail(breed: Breed) {
        breedPhoto.image = UIImage(named: breed.FullSizedPicture ?? "NoCatImage")
        breedName.text = breed.BreedName
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //toolbar.frame = CGRect(x: view.frame.maxX - (2 * toolbar.frame.width) - 13, y: toolbar.frame.minY, width: toolbar.frame.width, height: toolbar.frame.height)
        originalRect = toolbar.frame
    }
    
    func menuItemChoosen(option: Int) {
        //toolbar.frame = self.originalRect
        
        if priorChildViewController != nil {
            remove(asChildViewController: priorChildViewController!)
        }
        
        switch option {
        case 2:
            add(asChildViewController: infoViewController)
        case 1:
            add(asChildViewController: statsViewController)
        case 0:
            add(asChildViewController: galleryViewController)
        default: break
        }
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
            if priorChildViewController != nil {
                remove(asChildViewController: priorChildViewController!)
            }
        } else {
            filteredBreeds = [breed!]
        }
        
        showBreedDetail(breed: (filteredBreeds.first ?? breed)!)
    }
}
