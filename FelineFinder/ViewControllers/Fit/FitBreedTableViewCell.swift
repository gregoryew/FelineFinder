//
//  FitBreedTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

class FitBreedTableViewCell: UITableViewCell {

    @IBOutlet weak var BreedImage: UIImageView!
    @IBOutlet weak var BreedNameLabel: UILabel!
    @IBOutlet weak var BreedFitPercentageLabel: UILabel!
    
    var breedID: Int = -1
    
    @IBAction func BreedInfoTapped(_ sender: UIButton) {
        print("********** Breed ID = \(breedID)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(breed: Breed) {
        BreedNameLabel.text = breed.BreedName

        BreedFitPercentageLabel.text = "\(String(format: "%.0f", round(breed.Percentage * 100)))%"
        
        BreedImage.image = UIImage(named: breed.PictureHeadShotName)
        
        breedID = Int(breed.BreedID)
    }

}
