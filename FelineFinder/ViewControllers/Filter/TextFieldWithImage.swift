//
//  TextFieldWithSideButtons.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import UIKit

protocol textFieldButtons {
    func leftButtonTapped()
    func rightButtonTapped()
}

class UITextFieldWithButtons: UITextField {

    var buttonsDelegate: textFieldButtons!
    
    //MARK:- Set Image on the right of text fields

    func setupRightImage(imageName:String){
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightButton.addTarget(self, action: #selector(rightButtonAction), for:  .touchUpInside)
        if let image = UIImage(named: imageName) {
            rightButton.setImage(image, for: .normal)
        }
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rightView = rightButton
        rightViewMode = .always
    }
    
    @objc func rightButtonAction(sender: UIButton!) {
        buttonsDelegate.rightButtonTapped()
    }

 //MARK:- Set Image on left of text fields

    func setupLeftImage(imageName:String){
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        leftButton.addTarget(self, action: #selector(leftButtonAction), for:  .touchUpInside)
        if let image = UIImage(named: imageName) {
            leftButton.setImage(image, for: .normal)
        }
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        leftView = leftButton
        leftViewMode = .always
    }

    @objc func leftButtonAction(sender: UIButton!) {
        buttonsDelegate.leftButtonTapped()
    }
    
  }
