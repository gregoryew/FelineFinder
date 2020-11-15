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
