//
//  BaseQuestionViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/29/21.
//

import UIKit

class BaseQuestionViewController: UIViewController, PageObservation {

   var Question: Question?
   var Number: Int = -1
   
   var parentPageViewController: SurveyPageViewController!
   func getParentPageViewController(parentRef: SurveyPageViewController) {
      parentPageViewController = parentRef
   }
   
   func gotoPage(page: Int) {
      currentQuestion = page
       parentPageViewController.setViewControllers([parentPageViewController.pages[page]], direction: .forward, animated: true, completion: nil)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      configure()
   }
   
   func configure() {
        
   }

}
