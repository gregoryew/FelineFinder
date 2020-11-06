//
//  MainTabFitViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit
import Charts

protocol calcStats {
    func answerChanged(question: Int, answer: Int)
}

class MainTabFitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, calcStats {
    
    @IBOutlet weak var BreedTableView: UITableView!
    @IBOutlet weak var QuestionsTableView: UITableView!
    
    var breeds: [Breed] = []
    var titles:[String] = []
    var breedStats = BreedStatList()
    var responses: [response] = []
    var breedPercentages: [Double] = []
    var selectedBreedID: Int = 1
    var selectedBreedIndexPath: Int = 1
    var breedTraitValues: [Int: [BarChartDataEntry]] = [:]
    var breedsInChart = [Int]()
    let colors = ChartColorTemplates.colorful()
    
    let BREED_TV = 1
    let QUESTION_TV = 2
    
    var breedColors: [UIColor]?
    var breedSelected = [Bool](repeating: false, count: 66)
    var scrollPosition: UITableView.ScrollPosition = .middle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BreedTableView.dataSource = self
        BreedTableView.delegate = self
        BreedTableView.tag = BREED_TV
        QuestionsTableView.dataSource = self
        QuestionsTableView.delegate = self
        QuestionsTableView.tag = QUESTION_TV
        if (questionList.count == 0){
            questionList = QuestionList()
            questionList.getQuestions()
        }
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.breedPercentages = [Double](repeating: 0, count: 65)
            DispatchQueue.main.async(execute: {
                self.BreedTableView.reloadData()
            })
        }
        breedStats.getBreedStatListForAllBreeds()
        initializeResponses()
    }
    
    func initializeResponses() {
        for q in 0..<questionList.count {
            if q < 8 {
                responses.append(response(id: Int(questionList[q].QuestionID), p: 0, d: ""))
            } else {
                responses.append(response(id: Int(questionList[q].QuestionID), p: -1, d: "Any"))
            }
        }
    }
    
    func answerChanged(question: Int, answer: Int) {
        if question < 8 {
            responses[question].percentAnswer = answer
        } else {
            responses[question].descriptionAnswer = questionList[question].Choices[answer].Name
        }
        breedPercentages = breedStats.calcMatches(responses: responses)
        for i in 0..<breedPercentages.count {
            breeds[i].Percentage = breedPercentages[Int(breeds[i].BreedID) - 1]
        }
        breeds.sort { (Breed1, Breed2) -> Bool in
            //return (breedPercentages[Int(Breed1.BreedID) - 1], Breed1.BreedName) > (breedPercentages[Int(Breed2.BreedID) - 1], Breed2.BreedName)
            return (self.breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (self.breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
        }
        questionSelected = IndexPath(row: question, section: 0)
        scrollPosition = .middle
        DispatchQueue.main.async(execute: {
            /*
            var paths = [IndexPath].init(repeating: IndexPath(row: 0, section: 0), count: self.breeds.count)
            for i in 0..<paths.count {
                paths[i].row = i
            }
            self.BreedTableView.reloadRows(at: paths, with: .middle)
            */
            self.BreedTableView.reloadData()
            self.QuestionsTableView.reloadData()
            //self.QuestionsTableView.scrollToRow(at: <#T##IndexPath#>, at: <#T##UITableView.ScrollPosition#>, animated: <#T##Bool#>)
            //self.QuestionsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
            if indexPath.row < 8 {
                return CGFloat(78 + (breedsInChart.count > 0 ? 50 : 0) + (breedsInChart.count * 45))
            } else {
                return CGFloat(81)
            }
        } else {
            return CGFloat(120)
        }
    }
    
    var questionSelected = IndexPath(row: 0, section: 0)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == BREED_TV {
            selectedBreedID = Int(breeds[indexPath.row].BreedID)
            if !breedSelected[selectedBreedID] {
                if breedsInChart.count == colors.count {return}
                for i in 0...7 {
                    if breedTraitValues[i] == nil {
                        breedTraitValues[i] = []
                    }
                    let count = breedTraitValues[i]!.count + 1
                    breedTraitValues[i]!.append(BarChartDataEntry(x: Double(count), y: Double(breedStats.allBreedStats[selectedBreedID]![i].Percent)))
                }
                breedsInChart.append(selectedBreedID)
                breedSelected[selectedBreedID] = !breedSelected[selectedBreedID]
            } else {
                var pos = -1
                for i in 0..<breedsInChart.count {
                    if breedsInChart[i] == selectedBreedID {
                        pos = i
                        break
                    }
                }
                if pos > -1 {
                    breedsInChart.remove(at: pos)
                    for i in 0..<questionList.count - 2 {
                        for j in (pos)...(breedsInChart.count) {
                            breedTraitValues[i]?[j].x -= 1
                        }
                        breedTraitValues[i]?.remove(at: pos)
                    }
                    breedSelected[selectedBreedID] = !breedSelected[selectedBreedID]
                }
            }
            breeds.sort { (Breed1, Breed2) -> Bool in
                //return (breedPercentages[Int(Breed1.BreedID) - 1], Breed1.BreedName) > (breedPercentages[Int(Breed2.BreedID) - 1], Breed2.BreedName)
                return (self.breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (self.breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
            }
            DispatchQueue.main.async {
                self.BreedTableView.reloadData()
                self.QuestionsTableView.reloadData()
                self.QuestionsTableView.scrollToRow(at: self.questionSelected, at: self.scrollPosition, animated: false)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        questionSelected = QuestionsTableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        scrollPosition = .top
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == BREED_TV {
            let cell = (self.BreedTableView.dequeueReusableCell(withIdentifier: "Breed", for: indexPath) as! FitBreedTableViewCell)

            let breed = breeds[indexPath.row]

            var pos = -1
            for i in 0..<breedsInChart.count {
                if breedsInChart[i] == breed.BreedID {
                    pos = i
                    break
                }
            }
            
            if pos > -1 {
                cell.BreedImage.layer.borderWidth = 5
                let selectedColor = colors[pos]
                cell.BreedImage.layer.borderColor = selectedColor.cgColor
                cell.BreedNameLabel.backgroundColor = selectedColor
                cell.BreedFitPercentageLabel.backgroundColor = selectedColor
                cell.contentView.backgroundColor = selectedColor
            } else {
                cell.BreedImage.layer.borderWidth = 0
                cell.BreedImage.layer.borderColor = UIColor.clear.cgColor
                cell.BreedNameLabel.backgroundColor = UIColor.clear
                cell.BreedFitPercentageLabel.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.black
            }
            
            cell.configure(breed: breed)
            
            return cell
        } else {
            if (indexPath.row < 8) {
                let cell = (self.QuestionsTableView.dequeueReusableCell(withIdentifier: "slider", for: indexPath) as! FitQuestionSliderTableViewCell)

                let question = questionList[indexPath.row]

                cell.tag = indexPath.row
                cell.delegate = self
                var breedNames = [""]
                var breedPositions = [Int]()
                for i in 0..<breedsInChart.count {
                    var pos = -1
                    for j in 0..<breeds.count {
                        if breeds[j].BreedID == breedsInChart[i] {
                            pos = j
                            break
                        }
                    }
                    if pos > -1 {
                        breedNames.append(breeds[pos].BreedName)
                        breedPositions.append(pos)
                    }
                }
                let answer = responses[indexPath.row].descriptionAnswer == "Doesn't Matter" ? 0 : responses[indexPath.row].percentAnswer
                let answerValue = Float(Double(answer) / Double(question.getAnswer().HighRange))
                cell.configure(question: question, answer: answerValue, breedEntries: breedTraitValues[indexPath.row] ?? [], breedNamesParam: breedNames, breedPositionParams: breedPositions)
                                
                return cell
            } else {
                let cell = (self.QuestionsTableView.dequeueReusableCell(withIdentifier: "segment", for: indexPath) as! FitQuestionSegmentTableViewCell)

                let question = questionList[indexPath.row]
                
                cell.tag = indexPath.row
                cell.delegate = self
                cell.configure(question: question)

                return cell
            }
        }
    }

    func assignRandomColors() -> [UIColor] {
        var temp = [UIColor]()
        let increment = Int(16777215 / 65)
        for index in stride(from: 0, to: 16777215, by: increment) {
            temp.append(UIColor(hexString: String(format:"%02X", index)))
        }
        /*
        for _ in 0...65 {
            temp.swapAt(Int(arc4random_uniform(65)), Int(arc4random_uniform(65)))
        }
        */
        return temp
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
