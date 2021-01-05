//
//  FavoritesViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/9/20.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var favoritesContainerView: UIView!
    
    private var MainTabAdoptableCatsCollectionView:AdoptableCatsCollectionViewViewController {
        if(_MainTabAdoptableCatsCollectionView == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _MainTabAdoptableCatsCollectionView = storyboard.instantiateViewController(withIdentifier: "AdoptList") as? AdoptableCatsCollectionViewViewController
            
            _MainTabAdoptableCatsCollectionView?.view.tag = FAVORITES_VC
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: _MainTabAdoptableCatsCollectionView!)
        }
        return _MainTabAdoptableCatsCollectionView!
    }

    var _MainTabAdoptableCatsCollectionView:AdoptableCatsCollectionViewViewController?

    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        favoritesContainerView.addSubview(viewController.view)

        // Configure Child View
        favoritesContainerView.frame = view.bounds
        favoritesContainerView.autoresizingMask = [.flexibleWidth]
        
        MainTabAdoptableCatsCollectionView.view.frame = CGRect(x: 0, y: 0, width: favoritesContainerView.frame.width, height: favoritesContainerView.frame.height)

        // Notify Child View Controller
        viewController.didMove(toParent: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add(asChildViewController: MainTabAdoptableCatsCollectionView)
    }
}
