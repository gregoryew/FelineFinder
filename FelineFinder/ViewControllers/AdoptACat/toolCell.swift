//
//  toolCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit

class ToolCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var Title: UILabel!
    
    func configure(tool: Tool) {
        img.image = UIImage(named: tool.icon)
        Title.text = tool.title
    }
}

