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
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
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
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    @IBAction func GoBackTapped(_ sender: AnyObject) {
        _ = navigationController?.tr_popViewController()

        /*
        if whichSegueGlobal == "Edit" {
            performSegue(withIdentifier: "Choices", sender: nil)
        } else {
            performSegue(withIdentifier: "MainMenu", sender: nil)
        }
        */
    }
    
    func viewQuestionEntry(_ index: Int) -> QuestionEntryViewController? {
        if let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "QuestionEntryViewController") as? QuestionEntryViewController {
            page.currentQuestion = index
            return page
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Summary" {
            questionList.writeAnswers()
            (segue.destination as! SavedListsViewController).whichSegue = "Summary"
        }
    }
    
    @IBAction func SummaryTapped(_ sender: AnyObject) {
    performSegue(withIdentifier: "Summary", sender: nil)
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
                self.performSegue(withIdentifier: "Summary", sender: nil)
                return nil
            }
            guard index != questionList.count else {return nil}
            self.title = ""
            /*
            let vc = viewQuestionEntry(index)
            vc!.view.frame = viewController.view.bounds
            return vc
            */
            return viewQuestionEntry(index)
        }
        return nil
    }
    
    /*
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 2
    }
    */
 
    // MARK: UIPageControl
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        // 1
        return questionList.count
    }
    
    //func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        // 2
    //    return currentIndex ?? 0
    //}
    
    /*
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as PageContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        
        // Setting up the new view's frame
        var newVC = self.viewControllerAtIndex(index)
        newVC.view.frame = self.pageViewController.view.bounds
        return newVC
    }
    */
}
