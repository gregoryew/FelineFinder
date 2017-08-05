//
//  SurveyQuestionEntryViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/23/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import TTSegmentedControl

class SurveyQuestionEntryViewController: UIViewController {

    @IBOutlet weak var questionGif: FLAnimatedImageView!
    
    @IBOutlet weak var questionSlider: TicksSlider!
    
    @IBOutlet var slider: TicksSlider? = nil
    
    var segmentedControl: TTSegmentedControl? = nil
    
    var currentQuestion: Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UITextView!
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBAction func nextQuestion(_ sender: Any) {
        let mpvc = (parent) as! SurveyManagePageViewController
        currentQuestion = currentQuestion + 1
        if currentQuestion == 10 {
            questionList.writeAnswers()
            let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedSelections") as! SavedListsViewController
            savedLists.whichSegue = "Summary"
            mpvc.setViewControllers([savedLists], direction: .forward, animated: true, completion: nil)
        } else {
            let viewController = mpvc.viewQuestionEntry(currentQuestion)
            mpvc.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let frm = CGRect(x: 30, y: self.questionSlider.frame.minY + 10, width: questionLabel.frame.width - 30, height: self.questionSlider.frame.height)
        slider = TicksSlider(frame: (slider?.frame)!)
        slider?.minimumValue = 0
        slider!.maximumValue = 5
        slider!.statValue = 0
        slider!.value = 0
        slider?.didValueChange = { (value) -> () in
            print("Value \(value)")
            let q = questionList.Questions[self.currentQuestion]
            var i = 0
            if value == 0 {
               i = 0
            } else {
                i = 6 - value
            }
            questionList.Questions[self.currentQuestion].setAnswer(Int(q.Choices[i].ChoiceID))
        }
        self.view.addSubview(slider!)
        //slider?.center.x = self.view.center.x
        
        segmentedControl = TTSegmentedControl()
        segmentedControl?.allowChangeThumbWidth = false
        segmentedControl?.frame = frm
        //segmentedControl?.center.x = self.view.center.x
        segmentedControl?.didSelectItemWith = { (index, title) -> () in
            print("Selected item \(index)")
            let q = questionList.Questions[self.currentQuestion]
            print("")
            print("Displaying")
            print("Question \(q.Name)")
            print("Answer \(q.Choices[index - 1].Name)")
            questionList.Questions[self.currentQuestion].setAnswer(Int(q.Choices[index - 1].ChoiceID))
        }
        view.addSubview(segmentedControl!)
    
        displayQuestion()
        
        self.becomeFirstResponder()
    }
    
    func displayQuestion() {
        if ((currentQuestion < 0) || (currentQuestion >= questionList.Questions.count)) {return}

        titleLabel.text = questionList.Questions[currentQuestion].Name
        questionLabel.text = questionList.Questions[currentQuestion].Description
        questionNumberLabel.text = "Question \(currentQuestion + 1) out of \(questionList.Questions.count)"
        let answer = questionList.getAnswer(currentQuestion)
 
        if currentQuestion < 8 {
            slider!.isHidden = false
            segmentedControl!.isHidden = true
            var v = 0
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
            slider!.value = Double(v)
        } else {
            slider!.isHidden = true
            segmentedControl!.isHidden = false
            if currentQuestion == 8 {
                segmentedControl?.itemTitles = ["NA","Short","Med","Long"]
            } else {
                segmentedControl?.itemTitles = ["NA", "S", "M", "L"]
            }
            print("question \(questionList.Questions[currentQuestion].Name)")
            print("answer order \(answer.Order)")
            segmentedControl?.selectItemAt(index: Int(answer.Order - 1), animated: true)
        }
        
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
