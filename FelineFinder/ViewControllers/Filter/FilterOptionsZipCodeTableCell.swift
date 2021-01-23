//
//  FilterOptionsZipCodeCustomCellView.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/8/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class FilterOptionsZipCodeTableCell: UITableViewCell {
    @IBOutlet weak var ZipCodeTextbox: UITextField!
    
    func configure(zipCode: String) {
        ZipCodeTextbox.text = zipCode
    }
}
