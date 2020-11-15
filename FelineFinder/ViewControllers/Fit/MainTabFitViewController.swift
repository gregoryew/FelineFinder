//
//  MainTabFitViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

protocol calcStats {
    func answerChanged(question: Int, answer: Int)
}

class MainTabFitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, calcStats {
    
    @IBOutlet weak var QuestionsTableViews: UITableView!
    @IBOutlet weak var BreedTableView: UITableView!
    
    let BREED_TV = 1
    let QUESTION_TV = 2
    let COLORS = [UIColor.lightGreen, UIColor.lightPink, UIColor.lightBlue, UIColor.lightYellow, UIColor.darkOrange]
    let GRADIENTS = [UIColor.greenGradient, UIColor.pinkGradient, UIColor.blueGradient, UIColor.yellowGradient, UIColor.orangeGradient]

    var breedsInChartInfo = BreedsInChartInfo()
    var breedStats = BreedStatList()
    var responses: [response] = []
    var selectedBreedID: Int = 1
    var breedTraitValues: [Int: [PercentBarView]] = [:]
    var breedColors: [UIColor]?
    var breedSelected = [Bool](repeating: false, count: 68)
    var scrollPosition: UITableView.ScrollPosition = .middle
    var breeds = [Breed]()
    var breedPercentages = [Double]()
    var gradients = [CGGradient]()
    var colors = [UIColor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        BreedTableView.dataSource = self
        BreedTableView.delegate = self
        BreedTableView.tag = BREED_TV
        QuestionsTableViews.dataSource = self
        QuestionsTableViews.delegate = self
        QuestionsTableViews.tag = QUESTION_TV
        if (questionList.count == 0){
            questionList = QuestionList()
            questionList.getQuestions()
        }
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.breedPercentages = [Double](repeating: 0, count: 67)
            DispatchQueue.main.async(execute: {
                self.BreedTableView.reloadData()
                self.QuestionsTableViews.reloadData()
            })
        }
        breedStats.getBreedStatListForAllBreeds()
        initializeResponses()
        
        gradients = GRADIENTS
        colors = COLORS
    }
    
    func initializeResponses() {
        for q in 0..<questionList.count {
            if breedStats.allBreedStats[1]![q].isPercentage {
                responses.append(response(id: Int(questionList[q].QuestionID), p: 0, d: ""))
            } else {
                responses.append(response(id: Int(questionList[q].QuestionID), p: -1, d: "Any"))
            }
        }
    }
    
    func answerChanged(question: Int, answer: Int) {
        if breedStats.allBreedStats[1]![question].isPercentage {
            responses[question].percentAnswer = answer
        } else {
            responses[question].descriptionAnswer = questionList[question].Choices[answer].Name
        }

        guard breeds.count > 0 else {return}

        breedPercentages = breedStats.calcMatches(responses: responses)

        guard breedPercentages.count > 0 else {return}

        for i in 0..<breeds.count {
            breeds[i].Percentage = breedPercentages[Int(breeds[i].BreedID) - 1]
        }
        breeds.sort { (Breed1, Breed2) -> Bool in
            //return (breedPercentages[Int(Breed1.BreedID) - 1], Breed1.BreedName) > (breedPercentages[Int(Breed2.BreedID) - 1], Breed2.BreedName)
            return (self.breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (self.breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
        }
        questionSelected = IndexPath(row: question, section: 0)
        scrollPosition = .middle
        DispatchQueue.main.async(execute: {
            self.BreedTableView.reloadData()
            self.QuestionsTableViews.reloadData()
        })
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == BREED_TV {
            return breeds.count
        } else {
            return questionList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == QUESTION_TV {
            if breedStats.allBreedStats[1]![indexPath.row].isPercentage {
                return CGFloat(118 + (breedsInChartInfo.count > 0 ? 10 : 0) + (breedsInChartInfo.count * 30))
            } else {
                return CGFloat(81)
            }
        } else {
            return CGFloat(166)
        }
    }
    
    var questionSelected = IndexPath(row: 0, section: 0)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == BREED_TV {
            selectedBreedID = Int(breeds[indexPath.row].BreedID)
            if !breedSelected[selectedBreedID] {
                if breedsInChartInfo.count == colors.count {return}
                let index = breeds.firstIndex { (breed) -> Bool in
                    return breed.BreedID == selectedBreedID
                }
                guard index ?? -1 >= 0 && index ?? -1 < breeds.count else {return}
                var percents = [CGFloat]()
                for i in 0..<questionList.count {
                    if breedStats.allBreedStats[1]![indexPath.row].isPercentage {
                        percents.append(CGFloat(breedStats.allBreedStats[selectedBreedID]![i].Percent) / CGFloat(5.0))
                    }
                }
                let color = colors.popLast()
                let gradient = gradients.popLast()
                breedsInChartInfo.addBreed(id: selectedBreedID, percents: percents, title: breeds[index!].BreedName, gradient: gradient!, color: color!)
                breedSelected[selectedBreedID] = !breedSelected[selectedBreedID]
            } else {
                if let breed = breedsInChartInfo.getBreed(id: selectedBreedID) {
                    colors.append(breed.color!)
                    gradients.append(breed.gradient!)
                }
                breedsInChartInfo.removeBreed(id: selectedBreedID)
                breedSelected[selectedBreedID] = !breedSelected[selectedBreedID]
            }
            breeds.sort { (Breed1, Breed2) -> Bool in
                return (self.breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (self.breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
            }
            DispatchQueue.main.async {
                self.BreedTableView.reloadData()
                self.QuestionsTableViews.reloadData()
                self.QuestionsTableViews.scrollToRow(at: self.questionSelected, at: self.scrollPosition, animated: false)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        questionSelected = QuestionsTableViews.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        scrollPosition = .top
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == BREED_TV {
            let cell = (self.BreedTableView.dequeueReusableCell(withIdentifier: "Breed", for: indexPath) as! FitBreedTableViewCell)

            let breed = breeds[indexPath.row]
            
            if let color = breedsInChartInfo.getBreed(id: Int(breed.BreedID))?.color {
                cell.contentView.backgroundColor = color
            } else {
                cell.contentView.backgroundColor = UIColor.white
            }

            cell.configure(breed: breed)
            
            return cell
        } else {
            if (breedStats.allBreedStats[1]![indexPath.row].isPercentage) {
                let cell = (self.QuestionsTableViews.dequeueReusableCell(withIdentifier: "slider", for: indexPath) as! FitQuestionSliderTableViewCell)

                let question = questionList[indexPath.row]

                cell.tag = indexPath.row
                cell.delegate = self
                let answer = responses[indexPath.row].descriptionAnswer == "Doesn't Matter" ? 0 : responses[indexPath.row].percentAnswer
                let answerValue = Float(answer)
                cell.configure(question: question, answer: answerValue, bars: breedsInChartInfo.getBars(id: indexPath.row) ?? [])
                return cell
            } else {
                let cell = (self.QuestionsTableViews.dequeueReusableCell(withIdentifier: "segment", for: indexPath) as! FitQuestionSegmentTableViewCell)

                let answer = responses[indexPath.row].descriptionAnswer
                    
                let question = questionList[indexPath.row]
                
                cell.tag = indexPath.row
                cell.delegate = self
                cell.configure(question: question, answer: answer)

                return cell
            }
        }
    }
}

extension MainTabFitViewController: UIPopoverPresentationControllerDelegate {

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let popController = viewControllerToPresent.popoverPresentationController,
            popController.sourceView == nil{
            return
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
