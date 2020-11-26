//
//  BreedVideoCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/26/20.
//

import UIKit
import SDWebImage

class BreedVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var YouTubeThumbnail: UIImageView!
    
    func configure(video: youTubeTool) {
        YouTubeThumbnail.sd_setImage(with: URL(string: video.video.urlThumbnail), placeholderImage: UIImage(named: "NoCatImage"),  completed: nil)
    }
}
