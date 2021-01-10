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
        let fitDialogVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FitDialog") as! FitDialogViewController
        fitDialogVC.modalPresentationStyle = .formSheet
        if let viewController = self.getOwningViewController() {
            fitDialogVC.titleString = question?.Name ?? ""
            fitDialogVC.message = question?.Description ?? ""
            fitDialogVC.image = question?.ImageName ?? ""
            viewController.present(fitDialogVC, animated: false, completion: nil)
        }
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
        
        self.answers = answersParam
        
        QuestionLabel.text = question.Name
        
        print("collectionTag = \(self.segmentedCollectionView.tag) tag = \(tag) name = \(question.Name) count=\(answers.count) answer=\(answer) answers=\(answers)")
        
        selectionStyle = .none
        
        index = answers.firstIndex { (ans) -> Bool in
            return ans == answer || (ans == "Any" && answer == "Doesn\'t Matter")
        }
                
        self.question = question
        
        segmentedCollectionView.delegate = self
        segmentedCollectionView.dataSource = self
        let layout = segmentedCollectionView.collectionViewLayout as! MultiRowGradientLayout
        layout.delegate = self
        layout.cellPadding = 2.5
        
        DispatchQueue.main.async(execute: {
            if priorSelectedAnswers[self.tag] == -1 {
                self.segmentedCollectionView.reloadData()
                priorSelectedAnswers[self.tag] = 0
            } else {
                if self.index != priorSelectedAnswers[self.tag] {
                    //print("segment config priorCell=\(priorSelectedAnswers[self.tag]) currentCell = \(self.index)")
                    self.segmentedCollectionView.reloadItems(at: [IndexPath(item: priorSelectedAnswers[self.tag], section: 0), IndexPath(item: self.index ?? 0, section: 0)])
                    priorSelectedAnswers[self.tag] = self.index!
                }
            }
            self.segmentedCollectionView.reloadData()
        })
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
        print("tag = \(collectionView.tag)  collectionTag = \(collectionView.tag)  cellForItemAt = \(indexPath.row)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SegmentCollectionViewCell
        cell.configure(text: answers[indexPath.row], isSelected: index == indexPath.row)
        return cell
    }
}

extension String {
    func SizeOf(_ font: UIFont) -> CGSize {
        let size = self.size(withAttributes: [NSAttributedString.Key.font: font])
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return frame.scaleLinear(amount: 1.0).size
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
