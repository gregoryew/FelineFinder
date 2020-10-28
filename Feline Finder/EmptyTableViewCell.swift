//
//  EmptyTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/27/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var MessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(numberOfRows: Int, currentRow: Int, IsFavoriteMode: Bool) {
        if isFetchInProgress && !IsFavoriteMode {
            MessageLabel.text = "Please Wait While Cats Are Loading..."
        } else {
            if numberOfRows == 1 {
                if IsFavoriteMode {
                    MessageLabel.text = "Currently You Have No Favorites"
                } else {
                    MessageLabel.text = "Sorry nothing found.  Tap here for me to search once a day till found."
                }
            } else if numberOfRows == currentRow {
                MessageLabel.text = "End of Results.  Tap here for me to search once a day till found."
            }
        }
        self.superview?.setNeedsDisplay()
        self.superview?.setNeedsLayout()
    }

}
