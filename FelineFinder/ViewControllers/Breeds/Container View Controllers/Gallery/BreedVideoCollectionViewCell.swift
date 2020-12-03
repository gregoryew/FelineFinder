//
//  BreedVideoCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/26/20.
//

import UIKit
import SDWebImage
import YouTubePlayer

class BreedVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var YouTubeThumbnail: UIImageView!
    @IBOutlet weak var YouTubePlayer: YouTubePlayerView!
    
    var playButton = UIImageView()
    
    func configure(video: youTubeTool) {
        YouTubeThumbnail.sd_setImage(with: URL(string: video.video.urlThumbnail), placeholderImage: UIImage(named: "NoCatImage"),  completed: nil)
        
        playButton.image = UIImage(named: "Play")
        playButton.frame.size = playButton.image!.size
        
        self.contentView.addSubview(playButton)
        self.contentView.bringSubviewToFront(playButton)

        playButton.center = self.contentView.center
    }
}
