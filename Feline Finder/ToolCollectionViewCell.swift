//
//  ToolCollectionViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/21/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

class ToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ToolIcon: UILabel!
    
    func configure(tool: Tool) {
        ToolIcon.attributedText = setEmojicaLabel(text: tool.icon, size: 64.0)
    }
}
