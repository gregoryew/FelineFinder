//
//  BreedTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/11/21.
//

import UIKit

class BreedTableViewCell: UITableViewCell {
    @IBOutlet weak var BreedImage: UIImageView!
    @IBOutlet weak var BreedLabel: UILabel!
    
    override func prepareForReuse() {
        self.BreedImage.image = nil
        self.BreedImage.alpha = 0.33
        self.BreedLabel.text = ""
    }
    
    func configure(breed: BreedListItem) {
        self.BreedImage.image = UIImage(named: breed.breedImageName)
        choosen(selected[tag])
        self.BreedLabel.text = breed.breedName
    }
    
    func choosen(_ selected: Bool) {
        if selected {
            self.BreedImage.alpha = 1
        } else {
            self.BreedImage.alpha = 0.33
        }
    }
}
