//
//  BreedTabBarControllerViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 2/5/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class BreedTabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            if let controller = self.viewControllers![2] as? AdoptableCatsTabViewController {
                if let ob = controller.observer {
                    NotificationCenter.default.removeObserver(ob)
                }
            controller.pets = nil
            controller.locationManager = nil
            if controller.collectionView != nil {
            if (controller.collectionView?.infiniteScrollingHasBeenSetup)! {
                controller.collectionView?.infiniteScrollingHasBeenSetup = false
                controller.collectionView?.removeObserver((controller.collectionView?.infiniteScrollingView)!, forKeyPath: "contentOffset")
                controller.collectionView?.removeObserver((controller.collectionView?.infiniteScrollingView)!, forKeyPath: "contentSize")
                controller.collectionView?.infiniteScrollingView.resetScrollViewContentInset()
                //collectionView?.infiniteScrollingView.isObserving = false
            }
            }
            }
        }
    }
    
    deinit {
        print ("BreedTabBarControllerViewController deinit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
