//
//  FitQuestionSegmentTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit
import CoreFoundation

var priorSelectedAnswers = [Int](repeating: -1, count: 16)

class FitQuestionSegmentTableViewCell: UITableViewCell, MultiRowGradientLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var HelpButton: UIButton!
    
    @IBOutlet weak var segmentedCollectionView: UICollectionView!
    
    @IBAction func helpTapped(_ sender: Any) {
        if let vc = self.getOwningViewController() as? MainTabFitViewController {
            let index = questionList.Questions.firstIndex { Question in
                return Question.Name == question?.Name ?? ""
            }
            vc.gotoPage(page: index!)
        }
    }
    
    var delegate: calcStats?
    var question: Question?
    var fitloading = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var answers: [String] = []
    var index: Int?

    override func prepareForReuse() {
        super.prepareForReuse()
        answers = []
        question = nil
        delegate = nil
    }
    
    func configure(question: Question, answer: String, answers answersParam: [String]) {

        if tag != segmentedCollectionView.tag {
            return
        }

        segmentedCollectionView.delegate = self
        segmentedCollectionView.dataSource = self
        let layout = segmentedCollectionView.collectionViewLayout as! MultiRowGradientLayout
        layout.delegate = self
        layout.cellPadding = 2.5
        
        self.answers = answersParam
        
        QuestionLabel.text = question.Name
                
        selectionStyle = .none
        
        index = answers.firstIndex { (ans) -> Bool in
            return ans == answer || (ans == "Any" && answer == "Doesn\'t Matter")
        }
                
        self.question = question
                
        if priorSelectedAnswers[self.tag] == -1 {
            priorSelectedAnswers[self.tag] = 0
        } else {
            if self.index != priorSelectedAnswers[self.tag] {
                if let i = self.index {
                    priorSelectedAnswers[self.tag] = i
                } else {
                    priorSelectedAnswers[self.tag] = 0
                }
            }
        }
        
        if let tv = (self.findViewController() as!
        MainTabFitViewController).QuestionsTableViews {
            DispatchQueue.main.async(execute: {
                let offsety = tv.contentOffset
                let offsety2 = self.segmentedCollectionView.contentOffset
                self.segmentedCollectionView.reloadData()
                self.segmentedCollectionView.setContentOffset(offsety2, animated: false)
                tv.setContentOffset(offsety, animated: false)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        return self.answers[indexPath.item].SizeOf(UIFont.systemFont(ofSize: 15)).width + 10
    }
    
    func collectionView( _ collectionView: UICollectionView, maxHeight: CGFloat) {
        print("maxHeight tag = \(tag) maxHeight=\(maxHeight)")
        rowH[tag] = maxHeight + 50.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        delegate?.answerChanged(question: tag, answer: index!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SegmentCollectionViewCell
        cell.configure(text: answers[indexPath.row], isSelected: index == indexPath.row)
        return cell
    }
}
