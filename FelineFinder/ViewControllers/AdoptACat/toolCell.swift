//
//  toolCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit

class ToolCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    
    func configure(tool: Tool) {
        img.image = UIImage(named: tool.icon)
    }
}

