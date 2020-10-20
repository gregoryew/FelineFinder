//
//  FitQuestionSliderTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

extension UIResponder {
  
  func getOwningViewController() -> UIViewController? {
    var nextResponser = self
    while let next = nextResponser.next {
      nextResponser = next
      if let viewController = nextResponser as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

class FitQuestionSliderTableViewCell: UITableViewCell {

    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var HelpButton: UIButton!
    @IBOutlet weak var AnswerSlider: UISlider!
    
    var priorValue: Int = -1
    
    var delegate: calcStats?
    var question: Question?
    
    @IBAction func helpTapped(_ sender: Any) {
        let fitDialogVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FitDialog") as! FitDialogViewController
        fitDialogVC.modalPresentationStyle = .formSheet
        if let viewController = self.getOwningViewController() {
            fitDialogVC.titleString = question?.Name ?? ""
            fitDialogVC.message = question?.Description ?? ""
            fitDialogVC.image = question?.ImageName ?? ""
            viewController.present(fitDialogVC, animated: false, completion: nil)
        }
    }
    
    @IBAction func answerChanged(_ sender: Any) {
        var choice: Int = 0
        switch (AnswerSlider.value) {
        case 0.0..<0.01: choice = 0
        case 0.01..<0.2: choice = 1
        case 0.2..<0.4: choice = 2
        case 0.4..<0.6: choice = 3
        case 0.6..<0.8: choice = 4
        default: choice = 5
        }
        if priorValue == choice {return}
        priorValue = choice
        delegate?.answerChanged(question: tag, answer: choice)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(question: Question) {
        QuestionLabel.text = question.Name
        AnswerSlider.value = 0
        self.question = question
    }
}
