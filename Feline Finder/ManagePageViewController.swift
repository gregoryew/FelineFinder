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

class ManagePageViewController: UIPageViewController {
    var currentIndex: Int!
    
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
        
        self.title = questionList.Questions[0].Name
        
        // 1
        if let viewController = viewQuestionEntry(currentIndex ?? 0) {
            let viewControllers = [viewController]
            // 2
            setViewControllers(viewControllers,
                               direction: .Forward,
                               animated: false,
                               completion: nil)
        }
        
        
        //self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    @IBAction func GoBackTapped(sender: AnyObject) {
        if whichSegueGlobal == "Edit" {
            performSegueWithIdentifier("Choices", sender: nil)
        } else {
            performSegueWithIdentifier("MainMenu", sender: nil)
        }
    }
    
    func viewQuestionEntry(index: Int) -> QuestionEntryViewController? {
        if let storyboard = storyboard,
            page = storyboard.instantiateViewControllerWithIdentifier("QuestionEntryViewController") as? QuestionEntryViewController {
            page.currentQuestion = index
            return page
        }
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Summary" {
            questionList.writeAnswers()
            (segue.destinationViewController as! SavedListsViewController).whichSegue = "Summary"
        }
    }
    
    @IBAction func SummaryTapped(sender: AnyObject) {
    performSegueWithIdentifier("Summary", sender: nil)
    }
}

//MARK: implementation of UIPageViewControllerDataSource
extension ManagePageViewController: UIPageViewControllerDataSource {
    // 1
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? QuestionEntryViewController {
            var index = viewController.currentQuestion
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            self.title = questionList.Questions[index].Name
            return viewQuestionEntry(index)
        }
        return nil
    }
    
    // 2
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? QuestionEntryViewController {
            var index = viewController.currentQuestion
            guard index != NSNotFound else { return nil }
            index = index + 1
            if viewController.currentQuestion + 1 == questionList.count {
                self.performSegueWithIdentifier("Summary", sender: nil)
                return nil
            }
            self.title = questionList.Questions[index].Name
            guard index != questionList.count else {return nil}
            
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
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
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
