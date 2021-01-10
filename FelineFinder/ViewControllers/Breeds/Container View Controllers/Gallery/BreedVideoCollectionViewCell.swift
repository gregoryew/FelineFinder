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
        YouTubeThumbnail.sd_setImage(with: URL(string: tool.video.urlThumbnail), placeholderImage: UIImage(named: "NoCatImage"),  completed: nil)
        playButton.isHidden = false
        playButton.frame.origin = CGPoint(x: (133 / 2) - (Int(playButton.frame.size.width) / 2), y: (100 / 2) - (Int(playButton.frame.size.height) / 2))
        VideoTitle.text = tool.video.title
    }
}
