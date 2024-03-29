//
//  SurveyQuestionEntryViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/23/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import TTSegmentedControl

class SurveyQuestionEntryViewController: SurveyBaseViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var questionGif: FLAnimatedImageView!
    
    @IBOutlet weak var questionSlider: TicksSlider!
    
    @IBOutlet var slider: TicksSlider? = nil
    
    @IBOutlet weak var preferenceLabel: UILabel!
    
    var segmentedControl: TTSegmentedControl? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UITextView!
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBAction func nextQuestion(_ sender: Any) {
        //let mpvc = (parent) as! SurveyManagePageViewController
        //currentQuestion = currentQuestion + 1
            //let viewController = mpvc.viewQuestionEntry(currentQuestion)
            //mpvc.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
    }
    
    //var startPoint: CGPoint?
    
    var panGesture  = UIPanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = UIScreen.main.bounds.width
        
        let frm = CGRect(x: (screenWidth - (questionLabel.frame.width - 60)) / 2, y: self.questionSlider.frame.minY + 10, width: questionLabel.frame.width - 60, height: self.questionSlider.frame.height)
        segmentedControl = TTSegmentedControl()
        segmentedControl?.allowChangeThumbWidth = false
        segmentedControl?.frame = frm
        segmentedControl?.didSelectItemWith = { (index, title) -> () in
            print("Selected item \(index)")
            let q = questionList.Questions[self.currentQuestion]
            var i = 0
            if self.currentQuestion < 8 {
                if index == 0 {
                    i = 0
                } else {
                    i = 6 - index
                }
                questionList.Questions[self.currentQuestion].setAnswer(Int(q.Choices[i].ChoiceID))
            } else {
                print("")
                print("Displaying")
                print("Question \(q.Name)")
                print("Answer \(q.Choices[index - 1].Name)")
                questionList.Questions[self.currentQuestion].setAnswer(Int(q.Choices[index - 1].ChoiceID))
            }
            self.preferenceLabel.text = questionList.Questions[self.currentQuestion].getAnswer().Name
        }
        view.addSubview(segmentedControl!)
    
        displayQuestion()
        
        self.view.isMultipleTouchEnabled = true
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGesture.delegate = self as UIGestureRecognizerDelegate
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
        
        self.becomeFirstResponder()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let velocity = panGesture.velocity(in: self.view)
            print("y < x \(abs(velocity.y) < abs(velocity.x))")
            return abs(velocity.y) < abs(velocity.x)
        } else {
            print("true")
            return true
        }
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        //let translation = sender.translation(in: self.view)
        if sender.state == .ended {
            slider?.positionTracker()
        } else {
            let x = sender.location(in: self.slider).x
            let value = Double(x / ((slider?.frame.width)!)) * 5
            if (value >= 0) && (value <= 5) {
                slider?.value = value
                print("value = \(String(describing: slider?.value))")
            } else {
            
            }
        }
    }
    
    func displayQuestion() {
        if ((currentQuestion < 0) || (currentQuestion >= questionList.Questions.count)) {return}

        titleLabel.text = questionList.Questions[currentQuestion].Name
        questionLabel.text = questionList.Questions[currentQuestion].Description
        questionNumberLabel.text = "Question \(currentQuestion + 1) out of \(questionList.Questions.count)"
        let answer = questionList.getAnswer(currentQuestion)
        self.preferenceLabel.text = answer.Name
        
        if currentQuestion <= 8 {
            segmentedControl?.itemTitles = ["0", "1", "2", "3", "4", "5"]
        } else {
            segmentedControl?.itemTitles = ["0", "1", "2", "3"]
        }
        
        var v = Int(answer.Order - 1)
        if currentQuestion < 8 {
            switch answer.Order {
            case 1:
                v = 0
            case 6:
                v = 1
            case 5:
                v = 2
            case 4:
                v = 3
            case 3:
                v = 4
            case 2:
                v = 5
            default:
                v = 0
            }
        }
        segmentedControl?.selectItemAt(index: v, animated: true)
        
        var gifName = ""

        gifName = questionList.Questions[currentQuestion].ImageName
        let gif = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: "gif")!), options: .mappedIfSafe)
        let GIFImage: FLAnimatedImage = FLAnimatedImage(animatedGIFData: gif)
        self.questionGif.animatedImage = GIFImage
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
