//
//  mediaCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import SDWebImage

class mediaCell: UICollectionViewCell {
    @IBOutlet weak var img: DynamicImageView!
    
    override var isSelected: Bool {
        didSet  {
            img.alpha = self.isSelected ? 1 : 0.5
        }
    }
    
    func configure(mediaTool: Tool, isSelected: Bool) {
        img.alpha = 0.5
        if mediaTool is imageTool {
            if let thumbNail = mediaTool as? imageTool, let imgURL = URL(string: thumbNail.thumbNail.URL) {
                img.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"), options: .highPriority, completed: nil)
            }
        } else if mediaTool is youTubeTool {
            if let thumbNail = mediaTool as? youTubeTool, let imgURL = URL(string: thumbNail.video.urlThumbnail) {
                img.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"), options: .highPriority, completed: nil)
            }
        }
        let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        backgroundImage.backgroundColor = UIColor.black
        self.contentView.addSubview(backgroundImage)
        self.contentView.sendSubviewToBack(backgroundImage)
    }
}
