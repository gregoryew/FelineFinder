//
//  FilterOptionsZipCodeCustomCellView.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/8/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class FilterOptionsListTableCell: UITableViewCell {
    lazy var ListValue: UILabel = {
      let labelValue = UILabel(frame: .zero)
      labelValue.textColor = .black
      labelValue.font = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
      labelValue.numberOfLines = 0
      labelValue.lineBreakMode = NSLineBreakMode.byWordWrapping
      labelValue.translatesAutoresizingMaskIntoConstraints = false
      labelValue.isUserInteractionEnabled = true
      return labelValue
    }()

    lazy var ListName: UILabel = {
      let labelName = UILabel(frame: .zero)
      labelName.textColor = .black
      labelName.font = UIFont(name: "HelveticaNeue", size: 14.0)
      labelName.numberOfLines = 0
      labelName.translatesAutoresizingMaskIntoConstraints = false
      return labelName
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureLayout()
    }
    
    func configureLayout() {
        contentView.addSubview(ListName)
        contentView.addSubview(ListValue)
        contentView.backgroundColor = .lightGray
        ListName.backgroundColor = .lightGray
        ListValue.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            ListName.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 20),
            ListName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ListName.widthAnchor.constraint(equalToConstant: 115),
            ListName.heightAnchor.constraint(equalToConstant: 18),
            
            ListValue.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 20),
            ListValue.leadingAnchor.constraint(equalTo: ListName.trailingAnchor, constant: 20),
            ListValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: ListValue.bottomAnchor, constant: 20)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) not implemented")
    }
}
