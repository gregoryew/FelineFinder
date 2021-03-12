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
        self.prepareForReuse()
        self.BreedImage.image = nil
        self.BreedImage.alpha = 0.35
        self.BreedLabel.text = ""
    }
    
    func configure(breed: BreedListItem) {
        self.BreedImage.image = UIImage(named: breed.breedImageName)
        setSelected(breed.selected, animated: false)
        self.BreedLabel.text = breed.breedName
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.setSelected(selected, animated: animated)
        if selected {
            self.BreedImage.alpha = 1
        } else {
            self.BreedImage.alpha = 0.35
        }
    }
}
