//
//  SurveyManagePageViewControll.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/23/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import Foundation

class SurveyManagePageViewController: UIPageViewController {
    var currentIndex: Int!
    var chosenBreed: Breed?
    
    deinit {
        print ("SurveyManagePageViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self as UIPageViewControllerDataSource
        
        currentIndex = 0
        
        if (whichSegueGlobal == "Edit") {
            currentIndex = editWhichQuestionGlobal
        }
        if (questionList.count == 0){
            questionList = QuestionList()
            questionList.getQuestions()
        }
        
        //self.title = ""
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 1
        if let viewController = viewQuestionEntry(currentIndex ?? 0) {
            let viewControllers = [viewController]
            // 2
            setViewControllers(viewControllers,
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
    }
    
    func viewQuestionEntry(_ index: Int) -> UIViewController? {
        if index <= 9 {
            if
            let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "SurveyQuestionEntryViewController") as? SurveyQuestionEntryViewController {
                if index >= 0 {
                    page.currentQuestion = index
                } else {
                    page.currentQuestion = 0
                }
            return page
            }
        } else if index == 10 {
            questionList.writeAnswers()
            let page = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SurveySummary") as! SurveySummaryViewController
            //page.currentQuestion = index
            page.whichSegue = "Summary"
            return page
        } else {
            let page = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SurveyMatches") as! SurveyMatchesTableViewController
            page.currentQuestion = index
            if let b = chosenBreed {
                page.breed = b
            }
            page.whichSeque = "results"
            return page
        }
        return nil
    }
}

var currentIndex2 = 0

//MARK: implementation of UIPageViewControllerDataSource
extension SurveyManagePageViewController: UIPageViewControllerDataSource {
    // 1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? SurveyBaseViewController
            else {
                return nil
        }
        let cq = vc.currentQuestion
        if cq <= 0 {
            return nil
        } else {
            return viewQuestionEntry(cq - 1)
        }
    }
    
    // 2
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? SurveyBaseViewController
            else {
                return nil
        }
        
        let cq = vc.currentQuestion
        if cq > questionList.count {
            return nil
        } else {
            return viewQuestionEntry(cq + 1)
        }
    }
    
    // MARK: UIPageControl
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return questionList.count
    }
}
