//
//  BreedVideoCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/26/20.
//

import UIKit
//import SDWebImage
import Kingfisher
//import YouTubePlayer

class BreedVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var VideoTitle: UILabel!
    @IBOutlet weak var YouTubeThumbnail: UIImageView!
    
    var playButton = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        playButton = UIImageView()
        playButton.image = UIImage(named: "Play")
        playButton.frame.size = playButton.image!.size
        
        self.contentView.addSubview(playButton)
        self.contentView.bringSubviewToFront(playButton)

        playButton.center = self.contentView.center
    }
    
    override func prepareForReuse() {
        playButton.isHidden = true
    }
    
    func configure(tool: youTubeTool) {
        if let imgURL = URL(string: tool.video.urlThumbnail) {
            YouTubeThumbnail.kf.indicatorType = .activity
            YouTubeThumbnail.kf.setImage(with: imgURL)
            playButton.isHidden = false
            playButton.frame.origin = CGPoint(x: (133 / 2) - (Int(playButton.frame.size.width) / 2), y: (100 / 2) - (Int(playButton.frame.size.height) / 2))
            VideoTitle.text = tool.video.title
        } else {
            YouTubeThumbnail.image = UIImage(named: "NoCatImage")
        }
    }
}
