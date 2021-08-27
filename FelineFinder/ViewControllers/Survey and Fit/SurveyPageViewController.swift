//
//  SurveyPageViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit

protocol PageObservation: AnyObject {
        func getParentPageViewController(parentRef: SurveyPageViewController)
    }

class SurveyPageViewController: UIPageViewController {
    var pages = [BaseQuestionViewController]()
    
    override func viewDidLoad() {
      super.viewDidLoad()

      dataSource = self

      if questionList.count == 0 {
         questionList = QuestionList()
         questionList.getQuestions()
         
         breedStats.getBreedStatListForAllBreeds()
         initializeResponses()
      }
      
      for i in 0..<questionList.count {
         let question = questionList.Questions[i]
         var questionVC: BaseQuestionViewController?
         switch question.Name {
         case "Build", "Hair Type", "Zodicat":
            questionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SurveyCollectionViewQuestion") as! QuestionCollectionViewController
         default:
            questionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SurveyScaleQuestion") as! QuestionScaleViewController
         }
         if let vc = questionVC {
            let child1WithParent = vc
            child1WithParent.getParentPageViewController(parentRef: self)
            vc.Question = question
            vc.Number = i
            pages.append(vc)
         }
      }
      
      DatabaseManager.sharedInstance.fetchBreedsFit { (breedsParam) -> Void in
            breeds = breedsParam
      }
    
      breedPercentages = [Double](repeating: 0, count: 69)
      for i in 0..<breeds.count {
        breeds[i].Percentage = breedPercentages[Int(breeds[i].BreedID) - 1]
        
      }
        
      breeds.sort { (Breed1, Breed2) -> Bool in
        return (breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
      }
        
      let surveyVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "Fit") as? MainTabFitViewController
        let child1WithParent = surveyVC!
      child1WithParent.getParentPageViewController(parentRef: self)
      if let vc = surveyVC
      {
        pages.append(vc)
      }
     
      setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        
    }

}

extension SurveyPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let currentIndex = pages.firstIndex(of: viewController as! BaseQuestionViewController)!
        
        if currentIndex > 0 && currentIndex < pages.count - 1 {
            currentQuestion = currentIndex - 1
            return pages[currentIndex - 1]
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        let currentIndex = pages.firstIndex(of: viewController as! BaseQuestionViewController)!
                
        if currentIndex < pages.count - 1 {
            currentQuestion = currentIndex + 1
            return pages[currentIndex + 1]
        } else {
            return nil
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return questionList.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
