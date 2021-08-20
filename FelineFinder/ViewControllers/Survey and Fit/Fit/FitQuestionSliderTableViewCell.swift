//
//  FitQuestionSliderTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit
import MultiSlider

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

var breedNames = [String]()

class FitQuestionSliderTableViewCell: UITableViewCell {

    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var HelpButton: UIButton!
    @IBOutlet weak var BreedChart: GraphView!
    @IBOutlet weak var AnswerSliderView: UIView!
    
    @IBOutlet weak var AnswerSlider: MultiSlider!
    
    var priorValue: Int = -1
    
    var delegate: calcStats?
    var question: Question?
    var breedPositions = [Int]()
    
    @IBAction func helpTapped(_ sender: Any) {
        if let vc = self.getOwningViewController() as? MainTabFitViewController {
            let index = questionList.Questions.firstIndex { Question in
                return Question.Name == question?.Name ?? ""
            }
            currentQuestion = index!
            vc.gotoPage(page: currentQuestion)
        }
    }
    
    @IBAction func answerChanged(_ sender: Any) {
        let choice = Int(AnswerSlider!.value[0])
        if priorValue == choice {return}
        priorValue = choice
        delegate?.answerChanged(question: tag, answer: choice)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(question: Question, answer: Float, bars: [PercentBarView]) {
        BreedChart.bars = []
        if bars.count > 0 {
            BreedChart.bars.append(contentsOf: bars)
        }
        
        selectionStyle = .none
                
        QuestionLabel.text = question.Name
                
        BreedChart.frame = CGRect(x: AnswerSliderView!.frame.minX, y: BreedChart.frame.minY, width: self.contentView.frame.size.width, height: BreedChart.frame.height)
        
        BreedChart.setupView()
        AnswerSlider!.value = [CGFloat(answer)]
        self.question = question
    }
}
