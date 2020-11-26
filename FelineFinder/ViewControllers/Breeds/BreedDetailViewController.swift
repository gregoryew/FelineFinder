//
//  BreedDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedDetailViewController: UIViewController {
    @IBOutlet weak var breedPhoto: UIImageView!
    @IBOutlet weak var breedName: UILabel!

    var breed: Breed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breedPhoto.image = UIImage(named: breed?.FullSizedPicture ?? "NoCatImage")
        breedName.text = breed?.BreedName
    }

}
