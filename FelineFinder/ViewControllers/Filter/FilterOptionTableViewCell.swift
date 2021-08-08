//
//  FilterOptionTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import UIKit

protocol Options {
    func answerChanged(indexPath: IndexPath, answer: Int)
    func promptDeleteSave(save: String)
}

enum cellKind {
    case regular
    case deleteable
}

class FilterOptionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, MultiRowGradientLayoutDelegate, deleteSave {

    var delegate: Options!
    
    var optionCollectionView: UICollectionView!
    var titleLabel: UILabel!
    
    var option: filterOption!
    var indexPath = IndexPath(row: 0, section: 0)
    var optionStates = [Bool]()
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func configure(option: filterOption, indexPath: IndexPath) {
        self.option = option
        self.indexPath = indexPath
        
        titleLabel = UILabel()
        titleLabel.text = option.name ?? ""
        contentView.addSubview(titleLabel)
        titleLabel.frame.origin = CGPoint(x: 30, y: 0)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.frame.size.width = 90
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.constraints(size: CGSize(width: 90, height: titleLabel.frame.height + 5))
        titleLabel.baselineAdjustment = .alignCenters
        
        let layout = MultiRowGradientLayout()
        optionCollectionView = UICollectionView(frame: CGRect(x: titleLabel.frame.width, y: 0, width: contentView.frame.width - titleLabel.frame.width, height: contentView.frame.height), collectionViewLayout: layout)
        contentView.addSubview(optionCollectionView)
        optionCollectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        
        optionCollectionView.register(
            OptionValueCell.self,
            forCellWithReuseIdentifier: "option")
        
        layout.delegate = self
        layout.columnHeight = 35
        
        optionCollectionView.constraints(top: contentView.topAnchor, leading: titleLabel.trailingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        titleLabel.constraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: optionCollectionView.leadingAnchor, padding: UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 10))
        
        DispatchQueue.main.async(execute: {
            self.optionCollectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.option.optionsArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = optionCollectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as? GradientCollectionViewCell {
            let choosen = answers[self.indexPath.section, self.indexPath.row].firstIndex(of: indexPath.row)
            let kind = self.indexPath.section == 0 ? cellKind.deleteable : cellKind.regular
            if choosen != nil {
                print("DISPLAY NAME = \(String(describing: self.option.options[indexPath.item].displayName))")
                print("CHOOSE = \(String(describing: choosen))")
            }
            cell.configure(text: self.option.options[indexPath.item].displayName ?? "", indexPath: indexPath, choosen: (choosen != nil), kind: kind, tag: Int(self.option.options[indexPath.row].search ?? "-1") ?? -1)
            cell.delegate = self
            return  cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, widthForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        return self.option.options[indexPath.item].displayName!.SizeOf(UIFont.systemFont(ofSize: 16)).width + 40
    }
    
    func collectionView(_ collectionView: UICollectionView, maxHeight: CGFloat) {
        self.optionCollectionView.frame.size.height = maxHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.answerChanged(indexPath: self.indexPath, answer: indexPath.row)
    }
    
    func delete(save: String) {
        delegate.promptDeleteSave(save: save)
    }
}
