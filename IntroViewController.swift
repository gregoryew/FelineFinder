//
//  IntroViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 6/25/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation

class IntroViewController: UIViewController, ModalTransitionDelegate {
    @IBOutlet weak var IntroVideoImg: UIImageView!
    @IBOutlet weak var IntroVideoLabel: UILabel!
    
    @IBOutlet weak var SuggestABreedImg: UIImageView!
    @IBOutlet weak var SuggestABreedLabel: UILabel!
    
    
    @IBOutlet weak var SearchAdoptableBreedsImg: UIImageView!
    @IBOutlet weak var SearchAdoptableBreedsLabel: UILabel!

    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet weak var ScreenOnOffLabel: UILabel!
    
    @IBOutlet weak var ScreenOnOffSwitch: UISwitch!
    
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
        
        // Do any additional setup after loading the view, typically from a nib.
        let introViewImgtap = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.introVideoTapped))
        IntroVideoImg.addGestureRecognizer(introViewImgtap)
        IntroVideoImg.isUserInteractionEnabled = true
        let introViewLabeltap = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.introVideoTapped))
        IntroVideoLabel.addGestureRecognizer(introViewLabeltap)
        IntroVideoLabel.isUserInteractionEnabled = true
        
        let SuggestABreedImgTap = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.breedSuggestionTapped))
        SuggestABreedImg.addGestureRecognizer(SuggestABreedImgTap)
        SuggestABreedImg.isUserInteractionEnabled = true
        let SuggestABreedLabeltap = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.breedSuggestionTapped))
        SuggestABreedLabel.addGestureRecognizer(SuggestABreedLabeltap)
        SuggestABreedLabel.isUserInteractionEnabled = true
        
        let SearchAdoptableBreedsImgTap = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.lookAtACatBreedForAdoptionTapped))
        SearchAdoptableBreedsImg.addGestureRecognizer(SearchAdoptableBreedsImgTap)
        SearchAdoptableBreedsImg.isUserInteractionEnabled = true
        let SeaechAdoptableCatsLabeltap = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.lookAtACatBreedForAdoptionTapped))
        SearchAdoptableBreedsLabel.addGestureRecognizer(SeaechAdoptableCatsLabeltap)
        SearchAdoptableBreedsLabel.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        //self.navigationController?.setToolbarHidden(true, animated:false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationController?.setToolbarHidden(true, animated:false)
    }
    
    func introVideoTapped() {
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabBarControllerViewController
        
        details.selectedIndex = 5
        
        tr_presentViewController(details, method: DemoPresent.CIZoom(transImage: .cat), completion: {
            print("Present finished.")
        })

    }
    
    func breedSuggestionTapped() {
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabBarControllerViewController
        
        details.selectedIndex = 3
        
        tr_presentViewController(details, method: DemoPresent.CIZoom(transImage: .cat), completion: {
            print("Present finished.")
        })
    
    }
    
    func lookAtACatBreedForAdoptionTapped() {
        
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabBarControllerViewController
        
        details.selectedIndex = 1
        
        tr_presentViewController(details, method: DemoPresent.CIZoom(transImage: .cat), completion: {
            print("Present finished.")
        })
    }
}
