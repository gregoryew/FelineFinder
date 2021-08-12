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
   @IBOutlet weak var ClearCacheTapped: UIButton!
   
   @IBAction func ClearCache(_ sender: Any) {
      let allKeys = NSUbiquitousKeyValueStore.default.dictionaryRepresentation.keys
      for key in allKeys {
          NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
      }
      NSUbiquitousKeyValueStore.default.synchronize()
   }
   
    override func configure() {
        super.configure()
        if let question = Question {
            questionTitleLabel.text = question.Name
            questionDescriptionLabel.text = question.Description
         
         var choices: [String] = []
         choices.append("Any")
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
        }
    }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      scale.setIndex(FitValues[Number])
   }

    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            scaleDescriptionLabel.text = "Doesn't Matter"
        } else {
         scaleDescriptionLabel.text = Question?.Choices[Int(Question?.Choices.count ?? 6) - sender.index].Name
        }
        let currentQuestion = (self.view.findViewController() as! QuestionScaleViewController).Number
        var previousAnswer = 0
        for i in 0..<questionList[currentQuestion].Choices.count {
           if questionList[currentQuestion].Choices[i].Answer == true {
              previousAnswer = i
              break
           }
        }
        answerChangedGlobal(question: currentQuestion, answer: sender.index)
        if sender.index != previousAnswer {
           questionList[currentQuestion].Choices[previousAnswer].Answer = false
        }
    }
   
   @IBAction func GoToScoreBoardTapppd(_ sender: Any) {
      gotoPage(page: questionList.count)
   }
}
