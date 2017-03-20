//
//  BreedTabBarControllerViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 2/5/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class BreedTabBarControllerViewController: UITabBarController, NavgationTransitionable, TRTabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            tr_pushTransition = nil
            if let controller = self.viewControllers![2] as? AdoptableCatsTabViewController {
            if controller.pets?.task != nil {
                controller.pets?.task?.cancel()
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
        tr_pushTransition = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
