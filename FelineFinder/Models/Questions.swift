//
//  Questions.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/13/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct Choice{
    var QuestionID: Int32
    var ChoiceID: Int32
    var Name: String
    var LowRange: Int32
    var HighRange: Int32
    var Order: Int32
    var Answer: Bool = false
    init (questionid: Int32, choiceid: Int32, name: String, lowRange: Int32, highRange: Int32, order: Int32) {
        QuestionID = questionid
        ChoiceID = choiceid
        Name = name
        LowRange = lowRange
        HighRange = highRange
        Order = order
        if (Order == 1) {
            Answer = true
        }
    }
}

struct Question {
    var QuestionID: Int32
    var Name: String
    var Description: String
    var Order: Int32
    var Choices = [Choice]()
    var ImageName: String
    
    init (id: Int32, name: String, description: String, order: Int32, choices: [Choice], image: String) {
        QuestionID = id
        Name = name
        Description = description
        Order = order
        Choices = choices
        ImageName = image
    }
    
    mutating func setAnswer(_ choiceID: Int) {
        var j = 0
        var k = 0
        
        while j < Choices.count {
            Choices[j].Answer = false
            j += 1
        }

        while k < Choices.count {
            if (Int(Choices[k].ChoiceID) == choiceID) {
                Choices[k].Answer = true
                break
            }
            k += 1
        }
        
    }
    
    func getAnswer() -> Choice {
        var choosen: Choice = Choice(questionid: 0, choiceid: 0, name: "", lowRange: 0, highRange: 0, order: 0);
        for choice in Choices {
            if (choice.Answer == true) {
                choosen = choice;
            }
        }
        return choosen
    }
}

class QuestionList {
    var Questions = [Question]();
    var Choices = [Choice]();
    
    var databasePath = "";
    
    var count: Int {return Questions.count}
    
    subscript (index: Int) -> Question {
        get {
            return Questions[index]
        }
        set(newValue) {
            Questions[index] = newValue
        }
    }

    func getAnswer(_ index: Int) -> Choice {
        return Questions[index].getAnswer()
    }
    
    func setAnswer(_ index: Int, choiceID: Int) {
        var q: Int = 0
        var i = 0
        while i < Questions.count {
            if (Int(Questions[i].QuestionID) == index) {
                q = i
                break;
            }
            i += 1
        }
        Questions[q].setAnswer(choiceID)
    }
    
    func readAnswers(_ id: Int) {
        DatabaseManager.sharedInstance.readAnswers(Questions, id: id)
    }
    
    func setAnswers() {
        DatabaseManager.sharedInstance.setAnswers(Questions) {(questions) -> Void in
            self.Questions = questions
        }
    }

    func writeAnswers() {
        DatabaseManager.sharedInstance.writeAnswers(Questions)
    }

    func getQuestions() {
        DatabaseManager.sharedInstance.fetchQuestions() { (questions) -> Void in
            self.Questions = questions
        }
    }
}
