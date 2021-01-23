//
//  FilterOptionTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import UIKit

class FilterOptionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, MultiRowGradientLayoutDelegate {
    
    var optionCollectionView: UICollectionView!
    
    var option: filterOption!
    var indexPath = IndexPath(row: 0, section: 0)
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func configure(option: filterOption, indexPath: IndexPath) {
        self.option = option
        self.indexPath = indexPath
        
        let layout = MultiRowGradientLayout()
        optionCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        contentView.addSubview(optionCollectionView)
        self.optionCollectionView.constraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        optionCollectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        
        optionCollectionView.register(
            OptionLabelCell.self,
            forCellWithReuseIdentifier: "label")
        
        optionCollectionView.register(
            OptionValueCell.self,
            forCellWithReuseIdentifier: "option")
        
        layout.delegate = self
        layout.columnHeight = 35
        
        DispatchQueue.main.async(execute: {
            self.optionCollectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.option.optionsArray().count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            if let cell = optionCollectionView.dequeueReusableCell(withReuseIdentifier: "label", for: indexPath) as? OptionLabelCell {
                cell.configure(label: self.option.name ?? "")
                return  cell
            }
        } else {
            if let cell = optionCollectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as? OptionValueCell {
                cell.configure(text2: self.option.options[indexPath.item - 1].displayName ?? "")
                return  cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, widthForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        var value = ""
        if indexPath.row == 0 {
            value = self.option.name!
            return value.SizeOf(UIFont.systemFont(ofSize: 16)).width + 20
        } else {
            value = self.option.options[indexPath.item - 1].displayName!
            return value.SizeOf(UIFont.systemFont(ofSize: 16)).width + 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, maxHeight: CGFloat) {
        self.optionCollectionView.frame.size.height = maxHeight
        rowHeights[indexPath.section, indexPath.row] = maxHeight
    }
}
