//
//  FavoritesViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/9/20.
//

import UIKit

class FavoritesViewController: ParentViewController {
    @IBOutlet weak var favoritesContainerView: UIView!
    
    private var MainTabAdoptableCatsCollectionView:AdoptableCatsCollectionViewViewController {
        if(_MainTabAdoptableCatsCollectionView == nil) {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            _MainTabAdoptableCatsCollectionView = storyboard.instantiateViewController(withIdentifier: "AdoptList") as? AdoptableCatsCollectionViewViewController
            
            _MainTabAdoptableCatsCollectionView?.view.tag = FAVORITES_VC
            _MainTabAdoptableCatsCollectionView?.FilterButton.isHidden = true
        
            self.MainTabAdoptableCatsCollectionView.delegate = self
            
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
        loadingFavorites = true
        add(asChildViewController: MainTabAdoptableCatsCollectionView)
        loadingFavorites = false
    }
    
    //This should never be called because favorites is only on the main tab view controller
    override func Dismiss(vc: UIViewController) {
    }
    
    override func Download(reset: Bool) {
        DownloadManager.loadFavorites(reset: reset)
    }
    
    override func GetTitle(totalRows: Int) -> String {
        return "\(totalRows) Favorites."
    }

}
