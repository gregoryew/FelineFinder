//
//  ParentViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/18/21.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

class ParentViewController: UIViewController, AdoptionDelegate {
    
    func AdoptionDismiss(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
    }
    
    func Setup() -> String {
        return "Test"
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    @objc func willEnterForeground() {
        if displayResults {
            displayResults = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AdoptList") as! AdoptableCatsCollectionViewViewController
            vc.delegate = self
            vc.modalPresentationStyle = .formSheet
            UIApplication.topViewController()!.present(vc, animated: false, completion: nil)
        }
    }
    
    func Dismiss(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
    }

    func Download(reset: Bool) {
        DownloadManager.loadOfflineSearch(reset: reset, queryID: queryID)
    }

    func GetTitle(totalRows: Int) -> String {
        return String(totalRows) + " cats found"
    }
}
