//
//  BreedDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedDetailViewController: UIViewController, toolBar {
    @IBOutlet weak var breedPhoto: UIImageView!
    @IBOutlet weak var breedName: UILabel!
    @IBOutlet weak var toolbar: Toolbar!
    @IBOutlet weak var childContainerView: UIView!
    
    var breed: Breed?
    var priorChildViewController: UIViewController?
    
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

    private lazy var photosViewController: BreedPhotosViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedPhotos") as! BreedPhotosViewController

        viewController.breed = breed
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var videosViewController: BreedVideosViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedVideos") as! BreedVideosViewController

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
        childContainerView.autoresizingMask = [.flexibleHeight]

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
        breedPhoto.image = UIImage(named: breed?.FullSizedPicture ?? "NoCatImage")
        breedName.text = breed?.BreedName
        toolbar.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolbar.frame = CGRect(x: view.frame.maxX - (2 * toolbar.frame.width), y: toolbar.frame.minY, width: toolbar.frame.width, height: toolbar.frame.height)
    }
    
    func menuItemChoosen(option: Int) {
        
        if priorChildViewController != nil {
            remove(asChildViewController: priorChildViewController!)
        }
        
        switch option {
        case 0:
            add(asChildViewController: infoViewController)
        case 1:
            add(asChildViewController: statsViewController)
        case 2:
            add(asChildViewController: photosViewController)
        case 3:
            add(asChildViewController: videosViewController)
        default: break
        }
    }
    
}
