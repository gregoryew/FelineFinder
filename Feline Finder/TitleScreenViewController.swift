//
//  TitleScreenViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/6/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation

class TitleScreenViewController: UIViewController, ModalTransitionDelegate, NavgationTransitionable {
    
    var timer = Timer()
    var counter = 0
    
    @IBOutlet var background: UIView!
    
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var surveyTitle: UIImageView!
    @IBOutlet weak var breedsTitle: UIImageView!
    @IBOutlet weak var favoritesTitle: UIImageView!
    @IBOutlet weak var adoptTitle: UIImageView!
    @IBOutlet weak var savesTitle: UIImageView!
    
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let viewWithTag = background.viewWithTag(999) {
            viewWithTag.sendSubview(toBack: self.view)
        } else {
            print("No!")
        }
        
        var alpha = CGFloat(0.0)
        if titleLabelsAlreadyDisplayed {
            alpha = CGFloat(1.0)
        }
        
        self.surveyTitle.alpha = alpha
        self.breedsTitle.alpha = alpha
        self.favoritesTitle.alpha = alpha
        self.adoptTitle.alpha = alpha
        self.savesTitle.alpha = alpha
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    override func viewDidLayoutSubviews() {
        if UIDevice().model.hasPrefix("iPad") {
            surveyTitle.frame = CGRect(x: 10, y: -14, width: 100, height: 107)
            breedsTitle.frame = CGRect(x: 130, y: -14, width: 100, height: 107)
            favoritesTitle.frame = CGRect(x: 245, y: -15, width: 110, height: 107)
            savesTitle.frame = CGRect(x: 10, y: -13, width: 100, height: 107)
            adoptTitle.frame = CGRect(x: 140, y: -13, width: 88, height: 107)
        } else {
            surveyTitle.frame = CGRect(x: 0, y: -14, width: 88, height: 107)
            breedsTitle.frame = CGRect(x: 80, y: -13, width: 100, height: 107)
            favoritesTitle.frame = CGRect(x: 170, y: -15, width: 88, height: 107)
            savesTitle.frame = CGRect(x: -5, y: -10, width: 100, height: 107)
            adoptTitle.frame = CGRect(x: 90, y: -11, width: 88, height: 107)
        }
    }
    
    @IBAction func FindACatTouchUpInside(_ sender: AnyObject) {
        if questionList.count == 0 {
            let search = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! ManagePageViewController
            search.viewDidLoad()
            self.navigationController?.tr_pushViewController(search, method: DemoTransition.CIZoom(transImage: transitionImage.search), completion: {})
            return
        }
        
        let alertController = UIAlertController(title: "New Search?", message: "Do you want a new search or to keep the existing one?", preferredStyle: .alert)
        
        // Create the actions.
        let newAction = UIAlertAction(title: "New", style: .cancel) { action in
            NSLog("New Button Pressed");
            questionList = QuestionList()
            questionList.getQuestions()
            SearchTitle = "SUMMARY"
            let search = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! ManagePageViewController
            search.viewDidLoad()
            self.navigationController?.tr_pushViewController(search, method: DemoTransition.CIZoom(transImage: transitionImage.search), completion: {})
        }
        
        let existingAction = UIAlertAction(title: "Existing", style: .default) { action in
            let search = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! ManagePageViewController
            search.viewDidLoad()
            self.navigationController?.tr_pushViewController(search, method: DemoTransition.CIZoom(transImage: transitionImage.search), completion: {})
        }
        
        // Add the actions.
        alertController.addAction(newAction)
        alertController.addAction(existingAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomMargin.constant = 5
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        navigationItem.prompt = ""
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if !titleLabelsAlreadyDisplayed {
        UIView.animate(withDuration: 1.0, delay: 1.2, options: .curveEaseOut, animations: {
            self.surveyTitle.alpha = 1
            self.breedsTitle.alpha = 1
            self.favoritesTitle.alpha = 1
            self.adoptTitle.alpha = 1
            self.savesTitle.alpha = 1
        }, completion: { finished in
            titleLabelsAlreadyDisplayed = true
            print("Titles Appeared opened!")
        })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var breedsButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var savedSearchesButton: UIButton!
    @IBOutlet weak var adoptCats: UIButton!
   
    @IBAction func searchTapped(_ sender: Any) {
    }
    
    @IBAction func breedsTapped(_ sender: Any) {
        let master = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedList") as! MasterViewController
        master.viewDidLoad()
        navigationController?.tr_pushViewController(master, method: DemoTransition.CIZoom(transImage: transitionImage.list), completion: {})
    }
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBAction func favoritesTapped(_ sender: Any) {

        let favorites = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Favorites") as! FavoritesViewController
        favorites.viewDidLoad()
        navigationController?.tr_pushViewController(favorites, method: DemoTransition.CIZoom(transImage: transitionImage.heart))
    }
    
    func modalViewControllerDismiss(callbackData data: Any?) {
        tr_dismissViewController()
    }
    
    @IBAction func savedSearchesTapped(_ sender: Any) {
        let savedSearches = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedLists") as! SavedLists2ViewController
        navigationController?.tr_pushViewController(savedSearches, method: DemoTransition.CIZoom(transImage: transitionImage.save))
    }

    @IBAction func adoptCatsTapped(_ sender: Any) {
        let adoptACat = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "adoptACat") as! AdoptableCatsViewController
        let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "");
        globalBreed = breed
        navigationController?.tr_pushViewController(adoptACat, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
    }
    
    @IBAction func instructionsTapped(_ sender: Any) {
        let adoptACat = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "instructions") as! InstructionsViewController
        navigationController?.tr_pushViewController(adoptACat, method: DemoTransition.CIZoom(transImage: transitionImage.list))
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    func pop() {
        _ = navigationController?.tr_popViewController()
    }
}
