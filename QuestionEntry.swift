//
//  QuestionEntry.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/14/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit
import CoreMotion

var questionList: QuestionList = QuestionList()

class QuestionEntryViewController: UIViewController {

    @IBOutlet weak var HighButton: UIButton!
    @IBOutlet weak var MediumButton: UIButton!
    @IBOutlet weak var LowButton: UIButton!
    
    @IBOutlet weak var ShakeToClearLabel: UILabel!
    
    @IBAction func HighButtonTapped(_ sender: Any) {
        let q = questionList.Questions[currentQuestion]
        var answer = 0
        if currentQuestion == 8 { //Hair
            answer = 5
        } else if currentQuestion == 9 { //Size
            answer = 3
        } else {
            answer = 1
        }
        questionList.Questions[currentQuestion].setAnswer(Int(q.Choices[answer].ChoiceID))
        setButtonToAnswer(answer: 2, flipPage: true)
    }
    
    @IBAction func MediumTapped(_ sender: Any) {
        let q = questionList.Questions[currentQuestion]
        var answer = 0
        if currentQuestion == 8 { //Hair
            answer = 4
        } else if currentQuestion == 9 { //Size
            answer = 2
        } else {
            answer = 3
        }
        questionList.Questions[currentQuestion].setAnswer(Int(q.Choices[answer].ChoiceID))
        setButtonToAnswer(answer: 4, flipPage: true)
    }
    
    @IBAction func LowTapped(_ sender: Any) {
        let q = questionList.Questions[currentQuestion]
        var answer = 0
        if currentQuestion == 8 { //Hair
            answer = 2
        } else if currentQuestion == 9 { //Size
            answer = 1
        } else {
            answer = 5
        }
        questionList.Questions[currentQuestion].setAnswer(Int(q.Choices[answer].ChoiceID))
        setButtonToAnswer(answer: 6, flipPage: true)
    }
    
    func setButtonToAnswer(answer: Int, flipPage: Bool = false)  {
        HighButton.setImage(UIImage(named: "High_Unlit"), for: UIControl.State.normal)
        MediumButton.setImage(UIImage(named: "Med_Unlit"), for: UIControl.State.normal)
        LowButton.setImage(UIImage(named: "Low_Unlit"), for: UIControl.State.normal)
        switch answer {
        case 6:
            if !flipPage {
                ShakeToClearLabel.isHidden = false
            }
            LowButton.setImage(UIImage(named: "Low_Lit"), for: UIControl.State.normal)
        case 4:
            if !flipPage {
                ShakeToClearLabel.isHidden = false
            }
            MediumButton.setImage(UIImage(named: "Med_Lit"), for: UIControl.State.normal)
        case 2:
            if !flipPage {
                ShakeToClearLabel.isHidden = false
            }
            HighButton.setImage(UIImage(named: "High_Lit"), for: UIControl.State.normal)
        default: break
        }
        if (flipPage) {
            let mpvc = (parent) as! ManagePageViewController
            if (currentQuestion == questionList.count - 1) || (whichSegueGlobal == "Edit") {
                mpvc.gotoSummary()
            } else {
                currentQuestion = currentQuestion + 1
                let viewController = mpvc.viewQuestionEntry(currentQuestion)
                mpvc.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
            }
        }
        if currentQuestion == 8 {  //Hair Type
            LowButton.setTitle("Long Hair", for: .normal)
            MediumButton.setTitle("Medium", for: .normal)
            HighButton.setTitle("Short", for: .normal)
        } else if currentQuestion == 9 {  //Size
            LowButton.setTitle("Biggish", for: .normal)
            MediumButton.setTitle("Average", for: .normal)
            HighButton.setTitle("Small", for: .normal)
        } else {
            LowButton.setTitle("Low", for: .normal)
            MediumButton.setTitle("Medium", for: .normal)
            HighButton.setTitle("High", for: .normal)
        }
    }
    
    @IBOutlet weak var QuestionLabel: UILabel!
    
    @IBOutlet weak var PageNumbers: UIPageControl!
    
    //@IBOutlet weak var GIFWidth: NSLayoutConstraint!
    
    @IBOutlet weak var FLAnimatedGIF: FLAnimatedImageView!
    
    @IBAction func SummaryTouchUpInside(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "Summary", sender: nil)
    }
    
    //var questionList: QuestionList = QuestionList();
    var question: Question = Question(id: 0, name: "", description: "", order: 0, choices: [], image: "");
    var choice: Choice = Choice(questionid: 0, choiceid: 0, name: "", lowRange: 0, highRange: 0, order: 0);
    var currentQuestion: Int = 0
    /*
    var cQuestion: Int = 0;
    var currentQuestion: Int {
        get {
            return cQuestion
        }
        set(newQuestionID) {
            cQuestion = newQuestionID
            PageNumbers.currentPage = cQuestion
        }
    };
    */
    
    @IBAction func PageChange(_ sender: AnyObject) {
        currentQuestion = PageNumbers.currentPage
        displayQuestion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        displayQuestion()
        self.becomeFirstResponder()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let q = questionList.Questions[currentQuestion]
            questionList.Questions[currentQuestion].setAnswer(Int(q.Choices[0].ChoiceID))
            setButtonToAnswer(answer: 1, flipPage: false)
            ShakeToClearLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        view.layoutSubviews()
        //self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentQuestion == 0 {
            LowButton.twinkle()
            MediumButton.twinkle()
            HighButton.twinkle()
        }
    }
    
    func setupViewController() {
        //self.AnswerPicker.dataSource = self
        //self.AnswerPicker.delegate = self
/*
        if (whichSegue == "Edit") {
            currentQuestion = editWhichQuestion
        }
        else if (questionList.count == 0){
            questionList = QuestionList()
            questionList.getQuestions()
        }
        self.displayQuestion()
*/
 }
    
    /*
    @IBAction func swipeLeft(sender: AnyObject) {
        if (self.currentQuestion < questionList.Questions.count - 1) {
            self.currentQuestion += 1;
            self.displayQuestion()
        }
        else {
            self.performSegueWithIdentifier("Summary", sender: nil)
        }
    }
    
    @IBAction func swipeRight(sender: AnyObject) {
        if (self.currentQuestion > 0) {
            self.currentQuestion -= 1
            self.displayQuestion()
        }
    }
    */
    
    //func numberOfComponents(in pickerView: UIPickerView) -> Int {
    //    return 1;
    //}
    
    //func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //println(questionList.Questions.count)
    //    question = questionList.Questions[currentQuestion];
    //    return question.Choices.count;
    //}
    
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        question = questionList.Questions[currentQuestion];
        return question.Choices[row].Name
    }
    */
    
    func setPicture( _ answerNumber: Int, fromPicker: Bool = false) {
        var _answerNumber = answerNumber
        var i = 0
        while i < questionList.Questions[currentQuestion].Choices.count {
            questionList.Questions[currentQuestion].Choices[i].Answer = false
            i += 1
        }
        if fromPicker == false {
            _answerNumber -= 1
        }
        questionList.Questions[currentQuestion].Choices[_answerNumber].Answer = true;
        if currentQuestion == 12 {
            var gifName: String = ""
            switch _answerNumber {
            case 1:
                gifName = "Cornish Rex"
            case 2:
                gifName = "Abyssinian"
            case 3:
                gifName = "American_Curl"
            case 4:
                gifName = "Chat_Chartreux"
            case 5:
                gifName = "Manx_cat_crouching"
            case 6:
                gifName = "Norwegian_Forest_Cat"
            default:
                gifName = "Unknown"
            }
            let gif = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: "gif")!), options: .mappedIfSafe)
            let GIFImage: FLAnimatedImage = FLAnimatedImage(animatedGIFData: gif)
            self.FLAnimatedGIF.animatedImage = GIFImage
        } else if currentQuestion == 9 {
            var gifName: String = ""
            switch _answerNumber {
            case 1:
                gifName = "Sphynx_Red"
            case 2:
                gifName = "Abyssinian"
            case 3:
                gifName = "DevonRex"
            case 4:
                gifName = "Birman"
            case 5:
                gifName = "Persian"
            case 6:
                gifName = "American_Curl"
            default:
                gifName = "Unknown"
            }
            let gif = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: "gif")!), options: .mappedIfSafe)
            let GIFImage: FLAnimatedImage = FLAnimatedImage(animatedGIFData: gif)
            self.FLAnimatedGIF.animatedImage = GIFImage
            
        } else if currentQuestion == 10 {
            var gifName: String = ""
            switch _answerNumber {
            case 1:
                gifName = "American_Curl"
            case 2:
                gifName = "Abyssinian"
            case 3:
                gifName = "Savannah"
            default:
                gifName = "Unknown"
            }
            let gif = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: "gif")!), options: .mappedIfSafe)
            let GIFImage: FLAnimatedImage = FLAnimatedImage(animatedGIFData: gif)
            self.FLAnimatedGIF.animatedImage = GIFImage
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        setPicture(row, fromPicker: true)
    }
    
    func displayQuestion() {
        if ((currentQuestion < 0) || (currentQuestion >= questionList.Questions.count)) {return}
        if parent != nil {
            let mpvc = (parent) as! ManagePageViewController
            //if let navBar = self.navigationController?.navigationBar {
            mpvc.navigationController?.navigationItem.title = "Skip Question By Flipping Page"
        }
        //self.navigationItem.title = questionList.Questions[currentQuestion].Name;
        let title = questionList.Questions[currentQuestion].Name
        QuestionLabel.text = "\(title)\r\nQuestion \(currentQuestion + 1) out of \(questionList.Questions.count)\r\n\r\n" + questionList.Questions[currentQuestion].Description;
        //AnswerPicker.reloadAllComponents()
        PageNumbers.currentPage = currentQuestion
        let answer = questionList.getAnswer(currentQuestion)
        /*
        if (answer.Answer == true)
        {
            AnswerPicker.selectRow((Int)(answer.Order - 1), inComponent: 0, animated: false)
        } else {
            AnswerPicker.selectRow(0, inComponent: 0, animated: false)
        }
        */
        
        ShakeToClearLabel.isHidden = true
        
        if currentQuestion == 8 {
            if answer.Order == 6 {
                setButtonToAnswer(answer: 2)
            } else if answer.Order == 5 {
                setButtonToAnswer(answer: 4)
            } else if answer.Order == 3 {
                setButtonToAnswer(answer: 6)
            } else {
                setButtonToAnswer(answer: -1)
            }
        } else if currentQuestion == 9 {
            if answer.Order == 4 {
                setButtonToAnswer(answer: 2)
            } else if answer.Order == 3 {
                setButtonToAnswer(answer: 4)
            } else if answer.Order == 2 {
                setButtonToAnswer(answer: 6)
            } else {
                setButtonToAnswer(answer: -1)
            }
        } else {
            setButtonToAnswer(answer: Int(answer.Order))
        }
        
        var gifName = ""
        //if currentQuestion == 12 || currentQuestion == 13 || currentQuestion == 14 {
            //setPicture(Int(answer.Order))
        //} else {
            gifName = questionList.Questions[currentQuestion].ImageName
            let gif = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: "gif")!), options: .mappedIfSafe)
            let GIFImage: FLAnimatedImage = FLAnimatedImage(animatedGIFData: gif)
            self.FLAnimatedGIF.animatedImage = GIFImage
        //}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Summary" {
            questionList.writeAnswers()
            (segue.destination as! SavedListsViewController).whichSegue = "Summary"
        }
    }
}
