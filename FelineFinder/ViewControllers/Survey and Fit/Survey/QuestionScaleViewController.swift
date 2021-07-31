//
//  QuestionViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit
import BetterSegmentedControl
import SDWebImage

class QuestionScaleViewController: BaseQuestionViewController {

    @IBOutlet var questionTitleLabel: UILabel!
    @IBOutlet var questionDescriptionLabel: UILabel!
    @IBOutlet var scale: BetterSegmentedControl!
    @IBOutlet var scaleDescriptionLabel: UILabel!
    @IBOutlet var questionAnimatedControl: SDAnimatedImageView!
    @IBOutlet var pageControl: UIPageControl!
   
    override func configure() {
        super.configure()
        if let question = Question {
            questionTitleLabel.text = question.Name
            questionDescriptionLabel.text = question.Description
         
         var choices: [String] = []
         choices.append("NA")
         for i in 1...Int((Question?.Choices.count ?? 0) - 1) {
            choices.append(String(i))
         }
         
         scale.segments = LabelSegment.segments(withTitles: choices,
                                                               normalTextColor: .black,
                                                               selectedTextColor: .white)
         scale.addTarget(self,
                            action: #selector(QuestionScaleViewController.navigationSegmentedControlValueChanged(_:)),
                                for: .valueChanged)
         let animatedImage = SDAnimatedImage(named: question.ImageName + ".gif")
         scaleDescriptionLabel.text = Question?.Choices[0].Name
         questionAnimatedControl.image = animatedImage
         pageControl.currentPage = Int(question.Order)
        }
    }

    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            scaleDescriptionLabel.text = "Doesn't Matter"
        } else {
         scaleDescriptionLabel.text = Question?.Choices[Int(Question?.Choices.count ?? 6) - sender.index].Name
        }
    }
}
