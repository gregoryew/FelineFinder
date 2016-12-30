//
//  QuestionEntry.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/14/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit

var questionList: QuestionList = QuestionList()

class QuestionEntryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var AnswerPicker: UIPickerView!
    @IBOutlet weak var QuestionLabel: UILabel!
    
    @IBOutlet weak var PageNumbers: UIPageControl!
    
    @IBOutlet weak var GIFWidth: NSLayoutConstraint!
    
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
        //currentQuestion = PageNumbers.currentPage
        //displayQuestion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        displayQuestion()
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
    
    func setupViewController() {
        self.AnswerPicker.dataSource = self
        self.AnswerPicker.delegate = self
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //println(questionList.Questions.count)
        question = questionList.Questions[currentQuestion];
        return question.Choices.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        question = questionList.Questions[currentQuestion];
        return question.Choices[row].Name
    }
    
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
        } else if currentQuestion == 13 {
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
            
        } else if currentQuestion == 14 {
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
        //self.navigationItem.title = questionList.Questions[currentQuestion].Name;
        let title = questionList.Questions[currentQuestion].Name
        QuestionLabel.text = "\(title)\r\nQuestion \(currentQuestion + 1) out of \(questionList.Questions.count)\r\n\r\n" + questionList.Questions[currentQuestion].Description;
        AnswerPicker.reloadAllComponents()
        PageNumbers.currentPage = currentQuestion
        let answer = questionList.getAnswer(currentQuestion)
        if (answer.Answer == true)
        {
            AnswerPicker.selectRow((Int)(answer.Order - 1), inComponent: 0, animated: false)
        } else {
            AnswerPicker.selectRow(0, inComponent: 0, animated: false)
        }
        var gifName = ""
        if currentQuestion == 12 || currentQuestion == 13 || currentQuestion == 14 {
            setPicture(Int(answer.Order))
        } else {
            gifName = questionList.Questions[currentQuestion].ImageName
            let gif = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: "gif")!), options: .mappedIfSafe)
            let GIFImage: FLAnimatedImage = FLAnimatedImage(animatedGIFData: gif)
            self.FLAnimatedGIF.animatedImage = GIFImage
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Summary" {
            questionList.writeAnswers()
            (segue.destination as! SavedListsViewController).whichSegue = "Summary"
        }
    }
}
