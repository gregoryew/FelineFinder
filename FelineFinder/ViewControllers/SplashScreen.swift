//
//  SplashScreen.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/25/21.
//

import Foundation

class SplashScreenViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarControllerViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
