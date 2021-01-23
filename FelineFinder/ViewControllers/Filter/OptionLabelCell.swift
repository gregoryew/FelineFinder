//
//  OptionLabelCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import UIKit

class OptionLabelCell: UICollectionViewCell {
    
    var label: UILabel!
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func configure(label: String) {
        self.label = UILabel()
        
        contentView.addSubview(self.label)
        
        self.label.constraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        
        self.label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.label.font = UIFont.systemFont(ofSize: 14)
        self.label.text = "      " + label
    }
}
