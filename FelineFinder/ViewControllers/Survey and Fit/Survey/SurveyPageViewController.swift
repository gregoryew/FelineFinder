//
//  SurveyPageViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit

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
            vc.Question = question
            vc.Number = i
            pages.append(vc)
         }
      }
     
      setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SurveyPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let currentIndex = pages.firstIndex(of: viewController as! BaseQuestionViewController)!
        
        // This math will make the pages wrap around
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        let currentIndex = pages.firstIndex(of: viewController as! BaseQuestionViewController)!
        
        // This math will make the pages wrap around
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return questionList.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
