//
//  SurveyManagePageViewControll.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/23/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import Foundation
import TransitionTreasury
import TransitionAnimation

class SurveyManagePageViewController: UIPageViewController, NavgationTransitionable {
    var currentIndex: Int!
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("SurveyManagePageViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
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
        
        
        //self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated:false);
    }
 
   func GoBackTapped(_ sender: AnyObject) {
        //_ = navigationController?.tr_popViewController()
        //_ = navigationController?.tr_popToRootViewController()
        let title = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Title") as! TitleScreenViewController
        navigationController?.tr_pushViewController(title, method: DemoTransition.CIZoom(transImage: .cat))
    }
 */
    
    func viewQuestionEntry(_ index: Int) -> SurveyQuestionEntryViewController? {
        if index <= 10 {
            if
            let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "SurveyQuestionEntryViewController") as? SurveyQuestionEntryViewController {
            page.currentQuestion = index
            return page
        }
        }
        return nil
    }
    
    func gotoSummary() {
        questionList.writeAnswers()
        let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedSelections") as! SavedListsViewController
        savedLists.whichSegue = "Summary"
        navigationController?.tr_pushViewController(savedLists, method: DemoTransition.Slide(direction: DIRECTION.right))
    }
    
    /*
    @IBAction func SummaryTapped(_ sender: AnyObject) {
        gotoSummary()
    }
    */
}

//MARK: implementation of UIPageViewControllerDataSource
extension SurveyManagePageViewController: UIPageViewControllerDataSource {
    // 1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? SurveyQuestionEntryViewController {
            var index = viewController.currentQuestion
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            return viewQuestionEntry(index)
        }
        return nil
    }
    
    // 2
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? SurveyQuestionEntryViewController {
            var index = viewController.currentQuestion
            if viewController.currentQuestion == questionList.count - 1 {
                questionList.writeAnswers()
                let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedSelections") as! SavedListsViewController
                savedLists.whichSegue = "Summary"
                return savedLists
            }
            guard index != NSNotFound else { return nil }
            index = index + 1
            guard index != questionList.count + 1 else {return nil}
            return viewQuestionEntry(index)
        }
        return nil
    }
    
    // MARK: UIPageControl
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return questionList.count
    }
}
