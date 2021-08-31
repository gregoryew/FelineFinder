//
//  mediaCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import Kingfisher

class mediaCell: UICollectionViewCell {
    @IBOutlet weak var img: DynamicImageView!
    
    var playButton = UIImageView()
    
    override var isSelected: Bool {
        didSet  {
            img.alpha = self.isSelected ? 1 : 0.5
        }
    }
    
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
    
    func configure(mediaTool: Tool, isSelected: Bool) {
        img.alpha = 0.5
        if mediaTool is imageTool {
            if let thumbNail = mediaTool as? imageTool, let imgURL = URL(string: thumbNail.thumbNail.URL) {
                img.kf.indicatorType = .activity
                img.kf.setImage(with: imgURL)
                playButton.isHidden = true
            } else {
                img.image = UIImage(named: "NoCatImage")
            }
        } else if mediaTool is youTubeTool {
            if let thumbNail = mediaTool as? youTubeTool, let imgURL = URL(string: thumbNail.video.urlThumbnail) {
                img.kf.indicatorType = .activity
                img.kf.setImage(with: imgURL)
                playButton.isHidden = false
                playButton.frame.origin = CGPoint(x: (133 / 2) - (Int(playButton.frame.size.width) / 2), y: (100 / 2) - (Int(playButton.frame.size.height) / 2))
            } else {
                img.image = UIImage(named: "NoCatImage")
            }
        }
        self.isSelected = isSelected
        let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        backgroundImage.backgroundColor = UIColor.black
        self.contentView.addSubview(backgroundImage)
        self.contentView.sendSubviewToBack(backgroundImage)
    }
}
