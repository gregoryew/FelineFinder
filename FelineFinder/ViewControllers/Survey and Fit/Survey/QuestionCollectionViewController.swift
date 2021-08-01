//
//  QuestionWithPopupViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit

class QuestionCollectionViewController: BaseQuestionViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
   @IBOutlet var questionTitleLabel: UILabel!
   @IBOutlet var questionDescriptionLabel: UILabel!
   @IBOutlet var questionAnswer: UILabel!
   @IBOutlet var questionCollectionView: UICollectionView!
   @IBOutlet var pageControl: UIPageControl!
   
   override func configure() {
       super.configure()
       if let question = Question {
         currentQuestion = Number
         questionTitleLabel.text = question.Name
         questionDescriptionLabel.text = question.Description
         pageControl.currentPage = Int(question.Order)
         questionCollectionView.dataSource = self
         questionCollectionView.delegate = self

         DispatchQueue.main.async(execute: {
            self.questionCollectionView.reloadData()
         })
       }
   }

   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      let q = questionList[currentQuestion]
      var ans = ""
      var index = -1
      for i in 0..<q.Choices.count {
         if q.Choices[i].Answer {
            ans = q.Choices[i].Name + " Selected"
            index = i
            break
         }
      }
      questionCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: true)
      if ans == "Doesn\'t Matter Selected" {
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
       return CGSize(width: questionCollectionView.bounds.width, height: questionCollectionView.bounds.height - 10)
   }
   
   @IBAction func GoToScoreBoardTapppd(_ sender: Any) {
      gotoPage(page: questionList.count)
   }
}
