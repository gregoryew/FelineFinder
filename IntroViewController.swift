//
//  IntroViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 6/25/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class IntroViewController: ZoomAnimationViewController {
    
    @IBOutlet weak var IntroVideoImg: UIImageView!
    @IBOutlet weak var IntroVideoLabel: UILabel!
    
    @IBOutlet weak var SuggestABreedImg: UIImageView!
    @IBOutlet weak var SuggestABreedLabel: UILabel!
        
    @IBOutlet weak var SearchAdoptableBreedsImg: UIImageView!
    @IBOutlet weak var SearchAdoptableBreedsLabel: UILabel!
    
    @IBOutlet weak var ScreenOnOffLabel: UILabel!
    @IBOutlet weak var ScreenOnOffSwitch: UISwitch!
        
    @IBAction func IntroTapped(_ sender: Any) {
        let OnboardingViewController = OnboardingVideoViewController()
        OnboardingViewController.modalPresentationStyle = .custom
        OnboardingViewController.transitioningDelegate = self
       present(OnboardingViewController, animated: false, completion: nil)
    }
    
    @IBAction func BreedSuggestionTapped(_ sender: Any) {
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabBarControllerViewController
        details.selectedIndex = 3
        details.modalPresentationStyle = .custom
        details.transitioningDelegate = self
                
        present(details, animated: true, completion: nil)
    }
    
    @IBAction func AdoptTapped(_ sender: Any) {
        //let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabAdoptableCats") as! MainTabAdoptableCats
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabBarControllerViewController
        //details.selectedIndex = 1
        //details.modalPresentationStyle = .custom
        //details.transitioningDelegate = self
        
        present(details, animated: false, completion: nil)
    }
    
    @IBAction func ScreenOnOffSwitch(_ sender: Any) {
        let defaults = UserDefaults.standard
        if ScreenOnOffSwitch.isOn {
            ScreenOnOffLabel.text = "Screen On"
                    } else {
            ScreenOnOffLabel.text = "Screen Off"
        }
        defaults.set(!ScreenOnOffSwitch.isOn, forKey: "hideTitleScreen")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalBreed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
        
    }
}
