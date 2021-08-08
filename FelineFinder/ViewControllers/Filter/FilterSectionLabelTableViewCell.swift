//
//  FilterSectionLabel.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import Foundation
import UIKit

class FilterSectionLabelTableViewCell: UITableViewCell {
    var label: UILabel!
    var arrow: UIView!
    var arrowImg: UIImageView!
    var section = 0
    var tableView: UITableView?
    
    func config(section: Int, tableView: UITableView) {
        self.selectionStyle = .none
        self.section = section
        self.tableView = tableView
        let title = titleForHeaderInSection(section: section)
        self.arrow = UIView()
        self.arrow.constraints(size: CGSize(width: 25, height: 44))
        arrowImg = UIImageView()
        arrowImg.center = self.arrow.center
        arrow.addSubview(arrowImg)
        contentView.addSubview(arrow)
        
        if section >= 4 {
            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(headerTapped(_:))
            )
            addGestureRecognizer(tapGestureRecognizer)
            self.arrowImg.constraints(size: CGSize(width: 15, height: 15))
            arrowImg.image = UIImage(named: colapsed[section - 4] ? "filter_arrow_right" : "filter_arrow_down")
            arrowImg.contentMode = .scaleToFill
            arrowImg.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            arrow.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            tag = section
        }
        
        self.label = UILabel(frame: CGRect(x: 0, y: 2, width: contentView.frame.width - 25, height: 44))
        contentView.addSubview(label)
        label.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        label.textColor = #colorLiteral(red: 0.6235294118, green: 0.6235294118, blue: 0.6235294118, alpha: 1)
        self.label.text = title

        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.label.constraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: self.arrow.leadingAnchor)
        self.arrow.constraints(top: contentView.topAnchor, leading: label.trailingAnchor, bottom: contentView.bottomAnchor, trailing: self.contentView.trailingAnchor)
        self.arrowImg.constraints(centerX: self.arrow.centerXAnchor, centerY: self.arrow.centerYAnchor)
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        guard let section = sender?.view?.tag else { return }

        if section >= 4 {
            arrowImg.image = UIImage(named: colapsed[section - 4] ? "filter_arrow_right" : "filter_arrow_down")
            colapsed[section - 4] = !colapsed[section - 4]
            DispatchQueue.main.async(execute: {
                self.tableView?.reloadData()
            })
        }
    }

    func titleForHeaderInSection (section: Int) -> String? {
        switch section {
        case 0:
            return "   Saves"
        case 1:
            return "   Breeds"
        case 2:
            return "   Location"
        case 3:
            return "   Filtering Options"
        case 4:
            if filterType == FilterType.Simple {
                return "   Simple Options"
            } else {
                return "   Administrative"
            }
        case 5:
            return "   Compatiblity"
        case 6:
            return "   Personality"
        case 7:
            return "   Physical"
        default:
            return ""
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let _ = UIGraphicsGetCurrentContext() {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 10, y: 1))
            bezierPath.addLine(to: CGPoint(x: rect.size.width, y: 1))
            UIColor.lightGray.setStroke()
            bezierPath.lineWidth = 1
            bezierPath.stroke()
        }
    }
}
