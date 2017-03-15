/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Foundation
import TransitionTreasury
import TransitionAnimation


class ManagePageViewController: UIPageViewController, NavgationTransitionable {
    var currentIndex: Int!
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("ManagePageViewController deinit")
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
        
        self.title = ""
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated:false);
    }
    
    @IBAction func GoBackTapped(_ sender: AnyObject) {
        //_ = navigationController?.tr_popViewController()
        _ = navigationController?.tr_popToRootViewController()
    }
    
    func viewQuestionEntry(_ index: Int) -> QuestionEntryViewController? {
        if let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "QuestionEntryViewController") as? QuestionEntryViewController {
            page.currentQuestion = index
            return page
        }
        return nil
    }
    
    func gotoSummary() {
        questionList.writeAnswers()
        let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedSelections") as! SavedListsViewController
        savedLists.whichSegue = "Summary"
        navigationController?.tr_pushViewController(savedLists, method: DemoTransition.Slide(direction: DIRECTION.right))
    }
    
    @IBAction func SummaryTapped(_ sender: AnyObject) {
        gotoSummary()
    }
    
}

//MARK: implementation of UIPageViewControllerDataSource
extension ManagePageViewController: UIPageViewControllerDataSource {
    // 1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? QuestionEntryViewController {
            var index = viewController.currentQuestion
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            self.title = ""
            //
            return viewQuestionEntry(index)
        }
        return nil
    }
    
    // 2
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? QuestionEntryViewController {
            var index = viewController.currentQuestion
            guard index != NSNotFound else { return nil }
            index = index + 1
            if viewController.currentQuestion + 1 == questionList.count {
                gotoSummary()
                return nil
            }
            guard index != questionList.count else {return nil}
            self.title = ""
            return viewQuestionEntry(index)
        }
        return nil
    }
 
    // MARK: UIPageControl
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        // 1
        return questionList.count
    }
}
