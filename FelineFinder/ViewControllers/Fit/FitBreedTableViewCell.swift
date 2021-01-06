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
    var breed: Breed!
    @IBOutlet weak var BreedNameLabel: UILabel!
    @IBOutlet weak var BreedCellView: UIView!
    @IBOutlet weak var SelectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(breed: Breed) {
        
        BreedNameLabel.text = "\(String(format: "%.0f", round(breed.Percentage * 100)))% \( breed.BreedName)"
        
        if let photo = UIImage(named: "Cartoon \(breed.BreedName)") {
            BreedImage.image = photo
        } else {
            BreedImage.image = UIImage(named: "Cartoon Domestic Short Hair")
        }
        
        self.breed = breed
    }

    @IBAction func hiliteBreed(_ sender: Any) {
        let vc = self.findViewController() as! MainTabFitViewController
        vc.hiliteBreed(selectedBreedID: Int(breed.BreedID))
    }
}
