//
//  MainTabAdoptableCatsTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import SDWebImage

class MainTabAdoptableCatsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var breed: UILabel!
    @IBOutlet weak var Stats: UILabel!
    @IBOutlet weak var location: UILabel!
    
    func configure(pd: Pet?) {
        if let pd = pd {
            if let imgURL = URL(string: pd.getImage(0, size: "pnt")) {
            self.photo.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority, completed: nil)
            } else {
                self.photo.image = UIImage(named: "NoCatImage")
            }
            
            name.text = pd.name
            
            breed.text = pd.breeds.first
            
            var options = [String]()
            if pd.status != "" {
                options.append(pd.status)
            }
            if pd.age != "" {
                options.append(pd.age)
            }
            if pd.sex != "" {
                options.append(pd.sex)
            }
            if pd.size != "" {
                options.append(pd.size)
            }
            Stats.text = options.joined(separator: " | ")
            
            var location = [String]()
            if pd.location != "" {
                location.append(pd.location)
            }
            if pd.distance != 0 {
                location.append("\(pd.distance) Miles")
            }
            self.location.text = location.joined(separator: " - ")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
