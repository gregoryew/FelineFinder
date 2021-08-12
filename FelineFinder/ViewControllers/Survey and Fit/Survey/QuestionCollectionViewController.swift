//
//  QuestionWithPopupViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit

class QuestionCollectionViewController: BaseQuestionViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
   @IBOutlet weak var questionTitleLabel: UILabel!
   @IBOutlet weak var questionDescriptionLabel: UILabel!
   @IBOutlet weak var questionAnswer: UILabel!
   @IBOutlet weak var questionCollectionView: UICollectionView!
   @IBOutlet weak var QuestionLabel: UILabel!
   
   var indexPath = IndexPath(item: 0, section: 0)
   var ans = ""
   
   override func configure() {
       super.configure()
       if let question = Question {
         currentQuestion = Number
         questionTitleLabel.text = question.Name
         questionDescriptionLabel.text = question.Description
         questionCollectionView.dataSource = self
         questionCollectionView.delegate = self
         QuestionLabel.text = "Question \(currentQuestion + 1) out of \(questionList.count)"
         
         DispatchQueue.main.async(execute: {
            self.questionCollectionView.reloadData()
         })
       }
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      debugPrint("IndexPath=\(indexPath)")
      DispatchQueue.main.async {
         self.questionCollectionView.scrollToItem(at: self.indexPath, at: .centeredVertically, animated: true)
      }
      if ans == "Doesn\'t Matter Selected" || ans == "Any"  || ans == "" {
         questionAnswer.text = "Any Selected"
      } else {
         questionAnswer.text = ans
      }
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return Int(questionList[currentQuestion].Choices.count)
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "Cell",
        for: indexPath) as! QuestionCollectionViewCell
      let number = (view.findViewController() as! QuestionCollectionViewController).Number
      cell.tag = indexPath.item
      cell.configure(Number: number)
      return cell
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

      if (questionCollectionView.bounds.height - 10 <= 0) {
         return CGSize(width: 0, height: 0)
      } else {
         return CGSize(width: questionCollectionView.bounds.width, height: questionCollectionView.bounds.height - 10)
      }
   }
   
   @IBAction func GoToScoreBoardTapppd(_ sender: Any) {
      gotoPage(page: questionList.count)
   }
   
   @IBAction func NextTappedInside(_ sender: Any) {
      currentQuestion += 1
      gotoPage(page: currentQuestion)
   }
}
