//
//  OptionValueCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import UIKit

class OptionValueCell: GradientCollectionViewCell {
    
    var label: UILabel!
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func config(value: String) {
        /*
        label = UILabel()
        contentView.addSubview(label)
        self.label.constraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.label.text = value
        */
    }
}
