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

class IntroViewController: UIViewController, ModalTransitionDelegate, NavgationTransitionable {
    @IBOutlet weak var IntroVideoImg: UIImageView!
    @IBOutlet weak var IntroVideoLabel: UILabel!
    
    @IBOutlet weak var SuggestABreedImg: UIImageView!
    @IBOutlet weak var SuggestABreedLabel: UILabel!
    
    
    @IBOutlet weak var SearchAdoptableBreedsImg: UIImageView!
    @IBOutlet weak var SearchAdoptableBreedsLabel: UILabel!

    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated:false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationController?.setToolbarHidden(true, animated:false)
    }
    
    func introVideoTapped() {
        //Utilities.displayAlert("IntroVideoTapped", errorMessage: "IntroVideoTapped")
        let onboardingVideo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "onboarding") as! OnboardingVideoViewController
        self.navigationController?.tr_pushViewController(onboardingVideo, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
    }
    
    func breedSuggestionTapped() {
        //Utilities.displayAlert("Breed Suggestion", errorMessage: "Breed Suggestion")
        
        let survey = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! ManagePageViewController
        self.navigationController?.tr_pushViewController(survey, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
    }
    
    func lookAtACatBreedForAdoptionTapped() {
        //Utilities.displayAlert("lookAtACatBreedForAdoption", errorMessage: "lookAtACatBreedForAdoption")
        
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabBarControllerViewController
        let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "");
        globalBreed = breed
        navigationController?.tr_pushViewController(details, method: TRPushTransitionMethod.page, completion: {})
    }
}
