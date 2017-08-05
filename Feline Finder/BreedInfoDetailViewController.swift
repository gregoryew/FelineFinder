//
//  BreedInfoDetailViewController.swift
//  
//
//  Created by gregoryew1 on 6/30/17.
//
//

import UIKit
import Foundation
import TransitionTreasury
import TransitionAnimation

class BreedInfoDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    weak var modalDelegate: ModalViewControllerDelegate?
    
    @IBOutlet weak var BreedSubTitle: UILabel!
    @IBOutlet weak var ShortDescriptionTextView: UITextView!
    @IBOutlet weak var BreedImage: UIImageView!
    @IBOutlet weak var BreedTitle: UILabel!
    
    @IBOutlet weak var InfoButton: TopIconButton!
    @IBOutlet weak var GalleryButton: TopIconButton!
    @IBOutlet weak var StatsButton: TopIconButton!
    @IBOutlet weak var AdoptButton: TopIconButton!
    
    @IBOutlet weak var containerViewController: UIView!
    
    @IBAction func BreedInfoTapped(_ sender: Any) {
        updateView(viewToShow: BreedInfoDescriptionViewController, buttonName: "Info")
    }
    
    @IBAction func GallterTapped(_ sender: Any) {
        updateView(viewToShow: BreedInfoGalleryViewController, buttonName: "Gallery")
    }
    
    @IBAction func StatsTapped(_ sender: Any) {
        updateView(viewToShow: BreedInfoStatsViewController, buttonName: "Stats")
    }
    
    @IBAction func AdoptTapped(_ sender: Any) {
        updateView(viewToShow: BreedInfoAdoptViewController, buttonName: "Adopt")
    }
    
    @IBAction func BackTapped(_ sender: Any) {
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.BreedSubTitle.text = globalBreed?.BreedName
        self.BreedTitle.text = globalBreed?.BreedName
        self.ShortDescriptionTextView.text = globalBreed?.Description
        self.BreedImage.image = UIImage(named: (globalBreed?.PictureHeadShotName)!)
        
        self.tabBarController?.navigationItem.title = globalBreed?.BreedName
    }
        
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    func setupView() {
        
    }
    
    private lazy var BreedInfoDescriptionViewController: BreedInfoDescriptionViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedInfoDescriptionViewController") as! BreedInfoDescriptionViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()

    private lazy var BreedInfoGalleryViewController: BreedInfoGalleryViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedInfoGalleryViewController") as! BreedInfoGalleryViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()

    private lazy var BreedInfoStatsViewController: BreedInfoStatsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedInfoStatsViewController") as! BreedInfoStatsViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()

    private lazy var BreedInfoAdoptViewController: BreedInfoAdoptViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BreedInfoAdoptViewController") as! BreedInfoAdoptViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        containerViewController.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerViewController.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }

    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    var priorView: UIViewController?
    
    func updateView(viewToShow: UIViewController, buttonName: String) {
        if let pv = priorView {
            remove(asChildViewController: pv)
        }
        InfoButton.setImage(UIImage(named: "BreedInfoInfoIcon"), for: .normal)
        InfoButton.setTitleColor(UIColor.white, for: .normal)
        GalleryButton.setImage(UIImage(named: "BreedInfoGalleryIcon"), for: .normal)
        GalleryButton.setTitleColor(UIColor.white, for: .normal)
        StatsButton.setImage(UIImage(named: "BreedInfoStatsIcon"), for: .normal)
        StatsButton.setTitleColor(UIColor.white, for: .normal)
        AdoptButton.setImage(UIImage(named: "BreedInfoAdoptIcon"), for: .normal)
        AdoptButton.setTitleColor(UIColor.white, for: .normal)
        switch buttonName {
        case "Info":
            InfoButton.setImage(UIImage(named: "BreedInfoInfoIconUp"), for: .normal)
            InfoButton.setTitleColor(UIColor.black, for: .normal)
            break
        case "Gallery":
            GalleryButton.setImage(UIImage(named: "BreedInfoGalleryIconUp"), for: .normal)
            GalleryButton.setTitleColor(UIColor.black, for: .normal)
            break
        case "Stats":
            StatsButton.setImage(UIImage(named: "BreedInfoStatsIconUp"), for: .normal)
            StatsButton.setTitleColor(UIColor.black, for: .normal)
            break
        case "Adopt":
            AdoptButton.setImage(UIImage(named: "BreedInfoAdoptIconUp"), for: .normal)
            AdoptButton.setTitleColor(UIColor.black, for: .normal)
            break
        default: break
        }
        add(asChildViewController: viewToShow)
        priorView = viewToShow
    }
}
