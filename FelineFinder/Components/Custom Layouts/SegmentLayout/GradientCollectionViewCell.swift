//
//  GradientCollectionViewCell.swift
//  test
//
//  Created by Gregory Williams on 11/8/20.
//

import UIKit
import GradientButtonSwift

class GradientCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!

    func configure(text2: String) {
        button.setTitle(text2, for: .normal)
    }
}

extension CGRect {
    func scaleLinear(amount: Double) -> CGRect {
        guard amount != 1.0, amount > 0.0 else { return self }
        let ratio = CGFloat((1.0 - amount) / 2.0)
        return insetBy(dx: width * ratio, dy: height * ratio)
    }

    func scaleArea(amount: Double) -> CGRect {
        return scaleLinear(percent: sqrt(amount))
    }

    func scaleLinear(percent: Double) -> CGRect {
        return scaleLinear(amount: percent / 100)
    }

    func scaleArea(percent: Double) -> CGRect {
        return scaleArea(amount: percent / 100)
    }
}

extension UIColor {
    public class var lightGreen: UIColor {
        return #colorLiteral(red: 0.09316479415, green: 0.973489821, blue: 0.2888227105, alpha: 1)
    }
    public class var green: UIColor {
        return #colorLiteral(red: 0.008136845194, green: 0.8134655356, blue: 0.2534275949, alpha: 1)
    }
    public class var darkGreen: UIColor {
        return #colorLiteral(red: 0.003436810104, green: 0.6612920761, blue: 0.2257966399, alpha: 1)
    }
}
