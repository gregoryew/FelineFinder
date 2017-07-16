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
    }
    
    weak var modalDelegate: ModalViewControllerDelegate?
    
    @IBOutlet weak var DescriptionTextView: UITextView!
    @IBOutlet weak var BreedSubTitle: UILabel!
    @IBOutlet weak var ShortDescriptionTextView: UITextView!
    @IBOutlet weak var BreedImage: UIImageView!
    @IBOutlet weak var BreedTitle: UILabel!
    
    @IBOutlet weak var InfoButton: TopIconButton!
    @IBOutlet weak var GalleryButton: TopIconButton!
    @IBOutlet weak var StatsButton: TopIconButton!
    @IBOutlet weak var AdoptButton: TopIconButton!
    
    @IBAction func BreedInfoTapped(_ sender: Any) {
    }
    
    @IBAction func GallterTapped(_ sender: Any) {
    }
    
    @IBAction func StatsTapped(_ sender: Any) {
    }
    
    @IBAction func AdoptTapped(_ sender: Any) {
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
        
        self.DescriptionTextView.text = globalBreed?.Description
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
}
