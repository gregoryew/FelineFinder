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
   @IBOutlet weak var NextButton: GradientButton!
   @IBOutlet weak var QuestionLablel: UILabel!

   @IBAction func NextTappedInside(_ sender: Any) {
      currentQuestion += 1
      gotoPage(page: currentQuestion)
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
         
         let order = questionList.Questions.firstIndex { Question in
            return Question.Name == question.Name
         }
         
         QuestionLablel.text = "Question \((order ?? 0) + 1) out of \(questionList.count)"
        }
    }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      scale.setIndex(FitValues[Number])
      changeRate(rate: FitValues[Number])
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

      changeRate(rate: sender.index)
      
        answerChangedGlobal(question: currentQuestion, answer: sender.index)
        if sender.index != previousAnswer {
           questionList[currentQuestion].Choices[previousAnswer].Answer = false
        }
    }

   func changeRate(rate: Int) {
      switch rate {
      case 0: questionAnimatedControl.playbackRate = 1.00
      case 1: questionAnimatedControl.playbackRate = 0.33
      case 2: questionAnimatedControl.playbackRate = 0.66
      case 3: questionAnimatedControl.playbackRate = 1.00
      case 4: questionAnimatedControl.playbackRate = 1.33
      case 5: questionAnimatedControl.playbackRate = 1.66
      case 6: questionAnimatedControl.playbackRate = 2.00
      default: questionAnimatedControl.playbackRate = 1.00
      }
   }
   
   @IBAction func GoToScoreBoardTapppd(_ sender: Any) {
      gotoPage(page: questionList.count)
   }
}
