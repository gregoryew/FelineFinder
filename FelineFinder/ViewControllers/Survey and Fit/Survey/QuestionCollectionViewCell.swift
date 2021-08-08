//
//  QuestionCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
   @IBOutlet var image: UIImageView!
   @IBOutlet var title: UILabel!
   @IBOutlet var check: UIButton!

   func configure(Number: Int) {
      let currentQuestion = questionList[Number]
      if currentQuestion.Choices[self.tag].Name == "Doesn't Matter" {
         title.text = "Any"
      } else {
         title.text = currentQuestion.Choices[self.tag].Name
      }
      var imageName = "Any"

      if title.text == "Any" || title.text == "Long Hair" || title.text == "Short/Long Hair" {
         if title.text == "Short/Long Hair" {
            imageName = "Short Long"
         } else {
            imageName = title.text!
         }
         image.image = UIImage(named: imageName)
         changeImage(question: currentQuestion)
         return
      }
      
      let imageParts = currentQuestion.Choices[self.tag].Name.split(separator: " ")
      imageName = String(imageParts.count == 1 ? imageParts[0] : imageParts[1])
      image.image = UIImage(named: imageName)
      changeImage(question: currentQuestion)
   }
   
   override func prepareForReuse() {
      image.image = nil
      title.text = ""
      check.setImage(UIImage(named: "uncheckedBox"), for: .normal)
   }
   
   @IBAction func changeAnswer() {
      let vc = self.findViewController() as! QuestionCollectionViewController
      currentQuestion = vc.Number
      
      var previousAnswer = -1
      for i in 0..<questionList[currentQuestion].Choices.count {
         if questionList[currentQuestion].Choices[i].Answer == true {
            previousAnswer = i
            break
         }
      }
      vc.indexPath = IndexPath(item: self.tag, section: 0)
      vc.questionAnswer.text = questionList[currentQuestion].Choices[self.tag].Name + " Selected"
      vc.ans = vc.questionAnswer.text ?? ""
      answerChangedGlobal(question: currentQuestion, answer: self.tag)
      if self.tag == previousAnswer {
         questionList[currentQuestion].Choices[previousAnswer].Answer = false
      }
      changeImage(question: questionList[currentQuestion])
      DispatchQueue.main.async(
         execute: {
            (self.findViewController() as! QuestionCollectionViewController).questionCollectionView.reloadItems(at: [IndexPath(item: previousAnswer, section: 0)])
         }
      )
   }
   
   func changeImage(question: Question) {
      if question.Choices[self.tag].Answer {
         check.setImage(UIImage(named: "checkedBox"), for: .normal)
      } else {
         check.setImage(UIImage(named: "uncheckedBox"), for: .normal)
      }
   }
}
