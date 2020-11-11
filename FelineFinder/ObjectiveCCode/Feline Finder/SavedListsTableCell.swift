//
//  SavedListsTableCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/12/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class SavedListsTableCell: UITableViewCell {
    
/*
    var ss: SavedSearch?
    var ssview: SavedListsViewController?
    var whichQuestion: Int = 0
*/
 
    @IBOutlet weak var QuestionChoice: UILabel!
    
    @IBOutlet weak var QuestionAnswer: UIImageView!
    
 /*
    @IBAction func EditTouchUpInside(_ sender: AnyObject) {
        ssview?.whichQuestion = whichQuestion
        ssview?.performSegue(withIdentifier: "Edit", sender: nil)
   }
 */

    /*
    @IBAction func ResultsTouchUpInside(_ sender: AnyObject) {
        ssview?.performSegue(withIdentifier: "results", sender: nil)
    }
*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    */
    

    
}
