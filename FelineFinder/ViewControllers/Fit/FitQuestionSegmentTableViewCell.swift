//
//  FitQuestionSegmentTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class FitQuestionSegmentTableViewCell: UITableViewCell {
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var HelpButton: UIButton!
    @IBOutlet weak var AnswerSegment: BetterSegmentedControl!
    
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
    
    @IBAction func answerSegmentChanged(_ sender: Any) {
        delegate?.answerChanged(question: tag, answer: AnswerSegment.index)
    }
    
    var delegate: calcStats?
    var question: Question?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(question: Question, answer: String) {
        QuestionLabel.text = question.Name
        var answers:[String] = []
        if question.Name == "Hair Type" {
            answers.append("Any")
            answers.append("None")
            answers.append("Short")
            answers.append("Rex")
            answers.append("Med")
            answers.append("Long")
            //answers.append("S/L")
        } else if question.Name == "Build" {
            answers.append("Any")
            answers.append("Oriental")
            answers.append("Foreign")
            answers.append("Semi-Foreign")
            answers.append("Semi-Coby")
            answers.append("Cobby")
            answers.append("Substantial")
        } else {
            answers.append("Any")
            answers.append("Small")
            answers.append("Average")
            answers.append("Big")
        }
        selectionStyle = .none
        AnswerSegment.segments = LabelSegment.segments(withTitles: answers,
                                                                 normalFont: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
                                                                 normalTextColor: .white,
                                                                 selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!,
                                                                 selectedTextColor: .black)
        
        
        var index = answers.firstIndex { (ans) -> Bool in
            return ans == answer || (ans == "Any" && answer == "Doesn\'t Matter")
        }
        
        if answer == "Hairless" {index = 1}
        if answer == "Medium" {index = 4}
        if answer == "Long Hair" {index = 5}
        if answer == "Biggish" {index = 3}
        
        self.AnswerSegment.setIndex(index!)
        self.question = question
    }
}
