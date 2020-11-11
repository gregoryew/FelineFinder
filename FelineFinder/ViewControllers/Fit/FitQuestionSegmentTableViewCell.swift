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
    
    func configure(question: Question) {
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
        } else {
            answers.append("Any")
            answers.append("Small")
            answers.append("Average")
            answers.append("Big")
        }
        selectionStyle = .none
        //for answer in question.Choices {
        //    answers.append(answer.Name)
        //}
        AnswerSegment.segments = LabelSegment.segments(withTitles: answers,
                                                                 normalFont: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
                                                                 normalTextColor: .white,
                                                                 selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!,
                                                                 selectedTextColor: .black)

        self.question = question
    }

    
    
}
