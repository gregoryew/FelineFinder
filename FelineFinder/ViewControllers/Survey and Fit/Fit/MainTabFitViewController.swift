//
//  MainTabFitViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

var breedSelected = [Bool](repeating: false, count: 69)

protocol calcStats {
    func answerChanged(question: Int, answer: Int)
}

class MainTabFitViewController: BaseQuestionViewController, UITableViewDelegate, UITableViewDataSource, calcStats {
    
    @IBOutlet weak var QuestionsTableViews: UITableView!
    @IBOutlet weak var BreedTableView: UITableView!
    @IBOutlet weak var PeruseButton: GradientButton!
    @IBOutlet weak var ClearButon: GradientButton!
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        
        FitValues.clear()
        FitValues.storeIDs()
        questionList.getQuestions()
        initializeResponses()
        answerChangedGlobal(question: 0, answer: 0)
        calcAnswers(question: 0)
        DispatchQueue.main.async(execute: {
            self.BreedTableView.reloadData()
            self.QuestionsTableViews.reloadData()
        })
    }
    
    @IBAction func peruseButtonTapped(_ sender: Any) {
        let breedCards = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedCards") as! BreedCardsViewController
        breedCards.modalPresentationStyle = .fullScreen
        var selectedBreeds = [Breed]()
        for breedChart in breedsInChartInfo.breeds {
            selectedBreeds.append(breeds.first(where: { Breed in
                return Breed.BreedID == breedChart.breedID!
            })!)
        }
        if selectedBreeds.count == 0 {
            PeruseButton.shake()
            return
        }
        
        updateFilterBreeds(breedsParam: selectedBreeds)
        
        breedCards.breeds = selectedBreeds
        self.present(breedCards, animated: false, completion: nil)
    }
        
    let BREED_TV = 1
    let QUESTION_TV = 2
    let COLORS = [UIColor.lightGreen, UIColor.lightPink, UIColor.lightBlue, UIColor.lightYellow, UIColor.darkOrange]
    let GRADIENTS = [UIColor.greenGradient, UIColor.pinkGradient, UIColor.blueGradient, UIColor.yellowGradient, UIColor.orangeGradient]

    var breedsInChartInfo = BreedsInChartInfo()
    var selectedBreedID: Int = 1
    var breedTraitValues: [Int: [PercentBarView]] = [:]
    var breedColors: [UIColor]?
    var scrollPosition: UITableView.ScrollPosition = .middle
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
        gradients = GRADIENTS
        colors = COLORS
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        calcAnswers(question: 0)
        DispatchQueue.main.async(execute: {
            self.BreedTableView.reloadData()
            self.QuestionsTableViews.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == BREED_TV {
            let breedDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "breedDetail") as! BreedDetailViewController
            breedDetail.modalPresentationStyle = .fullScreen
            breed = breeds[indexPath.row]
            updateFilterBreeds(breedsParam: [breed!])
            self.present(breedDetail, animated: false, completion: nil)
        }
    }
    
    func answerChanged(question: Int, answer: Int) {
        answerChangedGlobal(question: question, answer: answer)
        calcAnswers(question: question)
    }

    func calcAnswers(question: Int) {
        guard breeds.count > 0 else {return}

        guard breedPercentages.count > 0 else {return}

        for i in 0..<breeds.count {
            breeds[i].Percentage = breedPercentages[Int(breeds[i].BreedID) - 1]
        }
        breeds.sort { (Breed1, Breed2) -> Bool in
            return (breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
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
                if rowH.count <= 0 || rowH.count < (indexPath.item - 1) || (rowH[indexPath.item] == 0){
                    return 200
                } else {
                    return rowH[indexPath.item] + 10
                }
            }
        } else {
            return CGFloat(177)
        }
    }
    
    var questionSelected = IndexPath(row: 0, section: 0)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        questionSelected = QuestionsTableViews.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        scrollPosition = .top
    }
    
    func hiliteBreed(selectedBreedID: Int) {
        if !breedSelected[selectedBreedID] {
            if breedsInChartInfo.count == colors.count {return}
            let index = breeds.firstIndex { (breed) -> Bool in
                return breed.BreedID == selectedBreedID
            }
            guard index ?? -1 >= 0 && index ?? -1 < breeds.count else {return}
            var percents = [CGFloat]()
            for i in 0..<questionList.count {
                if breedStats.allBreedStats[1]![i].isPercentage {
                    percents.append(CGFloat(breedStats.allBreedStats[selectedBreedID]![i].Percent) / CGFloat(5.0))
                }
            }
            let color = colors.popLast()
            if color == nil {
                BreedTableView.shake()
                return
            }
            let gradient = gradients.popLast()
            breedsInChartInfo.addBreed(id: selectedBreedID, percents: percents, title: breeds[index!].BreedName, gradient: gradient!, color: color!, imageName: breeds[index!].FullSizedPicture)
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
            return (breedSelected[Int(Breed1.BreedID)] ? "1" : "0", Breed1.Percentage, Breed2.BreedName) > (breedSelected[Int(Breed2.BreedID)] ? "1": "0", Breed2.Percentage, Breed1.BreedName)
        }
        if breedsInChartInfo.count == 0 {
            PeruseButton.setTitleColor(UIColor.lightGray, for: .normal)
            PeruseButton.backgroundColor = UIColor.systemGray
        } else {
            PeruseButton.setTitleColor(UIColor.white, for: .normal)
            PeruseButton.backgroundColor = UIColor.green
        }
        DispatchQueue.main.async {
            self.BreedTableView.reloadData()
            self.QuestionsTableViews.reloadData()
            self.QuestionsTableViews.scrollToRow(at: self.questionSelected, at: self.scrollPosition, animated: false)
        
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == BREED_TV {
            let cell = (self.BreedTableView.dequeueReusableCell(withIdentifier: "Breed", for: indexPath) as! FitBreedTableViewCell)

            let breed = breeds[indexPath.row]
            
            if let color = breedsInChartInfo.getBreed(id: Int(breed.BreedID))?.color {
                cell.BreedCellView.backgroundColor = color
            } else {
                cell.BreedCellView.backgroundColor = UIColor.white
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
                cell.segmentedCollectionView.tag = indexPath.row
                
                var answers = [String]()
                switch question.Name {
                case "Hair Type":
                    answers.append("Any")
                    answers.append("Hairless")
                    answers.append("Short")
                    answers.append("Rex")
                    answers.append("Medium")
                    answers.append("Long Hair")
                    break
                case "Build":
                    answers.append("Any")
                    answers.append("Oriental")
                    answers.append("Foreign")
                    answers.append("Semi-Foreign")
                    answers.append("Semi-Coby")
                    answers.append("Cobby")
                    answers.append("Drawf")
                    answers.append("Large")
                    answers.append("Medium")
                    answers.append("Moderate")
                    answers.append("Normal")
                    answers.append("Small")
                    break
                case "Size":
                    answers.append("Any")
                    answers.append("Small")
                    answers.append("Average")
                    answers.append("Biggish")
                    break
                case "Zodicat":
                    answers.append("Any")
                    answers.append("♒ Aquarius (Jan 20 - Feb 18)")
                    answers.append("♓ Pisces (Feb 19 - March 20)")
                    answers.append("♈ Aries (March 21 - Apr 19)")
                    answers.append("♉ Taurus (Apr 20 - May 20)")
                    answers.append("♊ Gemini (May 21 - Jun 20)")
                    answers.append("♋ Cancer (Jun 21 - July 22)")
                    answers.append("♌ Leo (July 23 - Aug 22)")
                    answers.append("♍ Virgo (Aug 23 - Sep 22)")
                    answers.append("♎ Libra (Sep 23 - Oct 22)")
                    answers.append("♏ Scorpio (Oct 23 - Nov 21)")
                    answers.append("♐ Sagittarius (Nov 22 - Dec 21)")
                    answers.append("♑ Capricorn (Dec 22 - Jan 19)")
                    break
                default: answers = []
                }
                
                cell.delegate = self
                cell.configure(question: question, answer: answer, answers: answers)
                
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

var rowH = [CGFloat](repeating: 0, count: 15)